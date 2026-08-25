import type { ServiceState } from '../types/graph.js'
import type { SimulationEvent } from '../types/simulation.js'
import {
  buildUpstreamMap,
  snapshotFromRuntime,
  type RecoveryAction,
  type ServiceRuntime,
  type SimulationConfig,
} from './types.js'
import type { Dependency } from '../types/graph.js'
import { evaluateDependencyPropagation } from './propagation.js'

export const DEFAULT_RECOVERY_DURATION = 6

function upstreamHealthy(
  runtime: ServiceRuntime,
  runtimeStates: Record<string, ServiceRuntime>,
  upstreamMap: Map<string, Dependency[]>,
): boolean {
  const upstream = upstreamMap.get(runtime.id) ?? []
  return upstream.every((dep) => {
    const source = runtimeStates[dep.sourceServiceId]
    if (!source) return true
    return source.state === 'HEALTHY' || source.state === 'RECOVERED'
  })
}

export function applyRecoveryStarts(
  runtimeStates: Record<string, ServiceRuntime>,
  recoveryActions: RecoveryAction[],
  simulationTime: number,
  recoveryDurations: Record<string, number>,
  events: SimulationEvent[],
): boolean {
  let changed = false
  const due = recoveryActions.filter((action) => action.startTime === simulationTime)

  for (const action of due) {
    const runtime = runtimeStates[action.serviceId]
    if (!runtime) continue
    if (runtime.state !== 'FAILED' && runtime.state !== 'DEGRADED') continue

    const previousState = runtime.state
    runtime.state = 'RECOVERING'
    runtime.recoveryTicksRemaining =
      recoveryDurations[action.serviceId] ?? DEFAULT_RECOVERY_DURATION
    runtime.stress = Math.max(runtime.stress - 0.25, 0)

    events.push({
      simulationTime,
      serviceId: runtime.id,
      eventType: 'RECOVERY_STARTED',
      previousState,
      newState: 'RECOVERING',
      reason: 'Recovery action initiated',
    })
    changed = true
  }

  return changed
}

export function processRecoveryProgress(
  runtimeStates: Record<string, ServiceRuntime>,
  simulationTime: number,
  events: SimulationEvent[],
): boolean {
  let changed = false

  for (const runtime of Object.values(runtimeStates)) {
    if (runtime.state !== 'RECOVERING' || runtime.recoveryTicksRemaining === null) continue

    runtime.recoveryTicksRemaining -= 1

    if (runtime.recoveryTicksRemaining <= 0) {
      runtime.state = 'RECOVERED'
      runtime.recoveryTicksRemaining = null
      runtime.disrupted = false
      runtime.stress = 0

      events.push({
        simulationTime,
        serviceId: runtime.id,
        eventType: 'RECOVERY_COMPLETED',
        previousState: 'RECOVERING',
        newState: 'RECOVERED',
        reason: 'Service recovery finished',
      })
      changed = true
    }
  }

  return changed
}

export function promoteRecoveredServices(
  runtimeStates: Record<string, ServiceRuntime>,
  upstreamMap: Map<string, Dependency[]>,
  simulationTime: number,
  events: SimulationEvent[],
): boolean {
  let changed = false

  for (const runtime of Object.values(runtimeStates)) {
    if (runtime.state !== 'RECOVERED') continue
    if (!upstreamHealthy(runtime, runtimeStates, upstreamMap)) continue

    runtime.state = 'HEALTHY'
    runtime.stress = 0
    events.push({
      simulationTime,
      serviceId: runtime.id,
      eventType: 'STABILIZED',
      previousState: 'RECOVERED',
      newState: 'HEALTHY',
      reason: 'Service returned to healthy operation',
    })
    changed = true
  }

  return changed
}

export function evaluateRecoveryPropagation(
  runtimeStates: Record<string, ServiceRuntime>,
  upstreamMap: Map<string, Dependency[]>,
  simulationTime: number,
  events: SimulationEvent[],
): boolean {
  return evaluateDependencyPropagation(runtimeStates, upstreamMap, simulationTime, events, {
    allowDeescalation: true,
  })
}

export function processRecoveryTick(
  runtimeStates: Record<string, ServiceRuntime>,
  upstreamMap: Map<string, Dependency[]>,
  recoveryActions: RecoveryAction[],
  recoveryDurations: Record<string, number>,
  simulationTime: number,
  events: SimulationEvent[],
): boolean {
  const started = applyRecoveryStarts(
    runtimeStates,
    recoveryActions,
    simulationTime,
    recoveryDurations,
    events,
  )
  const progressed = processRecoveryProgress(runtimeStates, simulationTime, events)
  const promoted = promoteRecoveredServices(
    runtimeStates,
    upstreamMap,
    simulationTime,
    events,
  )
  const propagated = evaluateRecoveryPropagation(
    runtimeStates,
    upstreamMap,
    simulationTime,
    events,
  )

  return started || progressed || promoted || propagated
}

export function allServicesHealthy(runtimeStates: Record<string, ServiceRuntime>): boolean {
  return Object.values(runtimeStates).every((runtime) => runtime.state === 'HEALTHY')
}

export interface RecoverySimulationContext {
  runtimeStates: Record<string, ServiceRuntime>
  dependencies: Dependency[]
  recoveryActions: RecoveryAction[]
  recoveryDurations: Record<string, number>
  config: SimulationConfig
  startTime: number
  firstDisruptionTime: number
}

export interface RecoverySimulationResult {
  events: SimulationEvent[]
  snapshots: ReturnType<typeof snapshotFromRuntime>[]
  finalStates: Record<string, ServiceState>
  recoveryTime: number
  completedAt: number
}

export function runRecoverySimulation(
  context: RecoverySimulationContext,
): RecoverySimulationResult {
  const {
    runtimeStates: initialStates,
    dependencies,
    recoveryActions,
    recoveryDurations,
    config,
    startTime,
    firstDisruptionTime,
  } = context

  if (recoveryActions.length === 0) {
    throw new Error('Select at least one service to recover.')
  }

  const runtimeStates = Object.fromEntries(
    Object.entries(initialStates).map(([id, runtime]) => [id, { ...runtime }]),
  )

  const upstreamMap = buildUpstreamMap(dependencies)
  const events: SimulationEvent[] = []
  const snapshots = [snapshotFromRuntime(startTime, runtimeStates)]

  let stableTicks = 0
  let simulationTime = startTime
  let recoveryCompleteTime: number | null = null

  while (simulationTime - startTime < config.durationSeconds) {
    simulationTime += config.tickSeconds
    const changed = processRecoveryTick(
      runtimeStates,
      upstreamMap,
      recoveryActions,
      recoveryDurations,
      simulationTime,
      events,
    )

    snapshots.push(snapshotFromRuntime(simulationTime, runtimeStates))

    if (allServicesHealthy(runtimeStates)) {
      if (recoveryCompleteTime === null) {
        recoveryCompleteTime = simulationTime
      }
      stableTicks += 1
      if (stableTicks >= 3) {
        events.push({
          simulationTime,
          serviceId: recoveryActions[0].serviceId,
          eventType: 'STABILIZED',
          reason: 'System stabilized after recovery',
        })
        break
      }
      continue
    }

    recoveryCompleteTime = null
    stableTicks = changed ? 0 : stableTicks + 1
    if (stableTicks >= 3) break
  }

  const finalRecoveryTime =
    recoveryCompleteTime !== null ? recoveryCompleteTime - firstDisruptionTime : 0

  return {
    events,
    snapshots,
    finalStates: Object.fromEntries(
      Object.entries(runtimeStates).map(([id, runtime]) => [id, runtime.state]),
    ),
    recoveryTime: finalRecoveryTime,
    completedAt: simulationTime,
  }
}
