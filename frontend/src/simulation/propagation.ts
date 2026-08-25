import type { ServiceState } from '@/types/graph'
import type { SimulationEvent } from '@/types/simulation'
import {
  eventTypeForTransition,
  markAffected,
  type Disruption,
  type ServiceRuntime,
} from '@/simulation/types'

const DEGRADED_THRESHOLD = 0.5
const FAILED_THRESHOLD = 1.0

interface PropagationOptions {
  allowDeescalation?: boolean
}

function upstreamStressContribution(state: ServiceState, strength: number): number {
  switch (state) {
    case 'FAILED':
      return strength
    case 'DEGRADED':
      return strength * 0.5
    case 'RECOVERING':
      return strength * 0.25
    case 'RECOVERED':
    case 'HEALTHY':
      return 0
    default:
      return 0
  }
}

function getActiveDisruptions(disruptions: Disruption[], simulationTime: number) {
  return disruptions.filter((disruption) => {
    if (disruption.startTime > simulationTime) return false
    if (disruption.duration === undefined) return true
    return simulationTime < disruption.startTime + disruption.duration
  })
}

export function applyDisruptions(
  runtimeStates: Record<string, ServiceRuntime>,
  disruptions: Disruption[],
  simulationTime: number,
  events: SimulationEvent[],
): boolean {
  let changed = false
  const active = getActiveDisruptions(disruptions, simulationTime)

  for (const disruption of active) {
    const runtime = runtimeStates[disruption.serviceId]
    if (!runtime) continue

    runtime.disrupted = true

    if (disruption.severity >= FAILED_THRESHOLD && runtime.state !== 'FAILED') {
      const previousState = runtime.state
      runtime.state = 'FAILED'
      runtime.stress = 1
      runtime.recoveryTicksRemaining = null
      markAffected(runtime, simulationTime, 'FAILED')
      events.push({
        simulationTime,
        serviceId: runtime.id,
        eventType: 'FAILURE',
        previousState,
        newState: 'FAILED',
        reason: 'Initial disruption applied',
      })
      changed = true
    } else if (
      disruption.severity >= DEGRADED_THRESHOLD &&
      runtime.state === 'HEALTHY'
    ) {
      runtime.state = 'DEGRADED'
      runtime.stress = disruption.severity
      markAffected(runtime, simulationTime, 'DEGRADED')
      events.push({
        simulationTime,
        serviceId: runtime.id,
        eventType: 'DEGRADATION',
        previousState: 'HEALTHY',
        newState: 'DEGRADED',
        reason: 'Partial disruption applied',
      })
      changed = true
    }
  }

  return changed
}

export function evaluateDependencyPropagation(
  runtimeStates: Record<string, ServiceRuntime>,
  upstreamMap: Map<string, { sourceServiceId: string; dependencyStrength: number }[]>,
  simulationTime: number,
  events: SimulationEvent[],
  options: PropagationOptions = {},
): boolean {
  const { allowDeescalation = false } = options
  let changed = false

  for (const runtime of Object.values(runtimeStates)) {
    if (runtime.state === 'RECOVERING' || runtime.state === 'RECOVERED') continue
    if (runtime.state === 'FAILED' && runtime.disrupted && !allowDeescalation) continue

    const upstream = upstreamMap.get(runtime.id) ?? []
    let stress = 0

    for (const dep of upstream) {
      const upstreamRuntime = runtimeStates[dep.sourceServiceId]
      if (!upstreamRuntime) continue
      stress += upstreamStressContribution(upstreamRuntime.state, dep.dependencyStrength)
    }

    runtime.stress = Math.min(stress, 1.5)

    const previousState = runtime.state
    let nextState: ServiceState = previousState

    if (stress >= FAILED_THRESHOLD && previousState !== 'FAILED') {
      nextState = 'FAILED'
    } else if (stress >= DEGRADED_THRESHOLD && previousState === 'HEALTHY') {
      nextState = 'DEGRADED'
    } else if (
      stress >= FAILED_THRESHOLD &&
      previousState === 'DEGRADED' &&
      !runtime.disrupted
    ) {
      nextState = 'FAILED'
    } else if (allowDeescalation) {
      if (previousState === 'FAILED' && !runtime.disrupted && stress < DEGRADED_THRESHOLD) {
        nextState = stress >= DEGRADED_THRESHOLD ? 'DEGRADED' : 'HEALTHY'
      } else if (previousState === 'DEGRADED' && stress < DEGRADED_THRESHOLD) {
        nextState = 'HEALTHY'
      } else if (
        previousState === 'FAILED' &&
        !runtime.disrupted &&
        stress >= DEGRADED_THRESHOLD &&
        stress < FAILED_THRESHOLD
      ) {
        nextState = 'DEGRADED'
      }
    }

    if (nextState !== previousState) {
      runtime.state = nextState
      if (nextState === 'HEALTHY') {
        runtime.stress = 0
      }
      markAffected(runtime, simulationTime, nextState)
      events.push({
        simulationTime,
        serviceId: runtime.id,
        eventType: eventTypeForTransition(previousState, nextState),
        previousState,
        newState: nextState,
        reason: allowDeescalation
          ? 'Dependency stress reduced during recovery'
          : 'Upstream dependency failure propagation',
      })
      changed = true
    }
  }

  return changed
}

export function processSimulationTick(
  runtimeStates: Record<string, ServiceRuntime>,
  upstreamMap: Map<string, { sourceServiceId: string; dependencyStrength: number }[]>,
  disruptions: Disruption[],
  simulationTime: number,
  events: SimulationEvent[],
): boolean {
  const disruptionChanged = applyDisruptions(
    runtimeStates,
    disruptions,
    simulationTime,
    events,
  )
  const propagationChanged = evaluateDependencyPropagation(
    runtimeStates,
    upstreamMap,
    simulationTime,
    events,
  )
  return disruptionChanged || propagationChanged
}
