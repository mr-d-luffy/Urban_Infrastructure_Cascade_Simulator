import { processSimulationTick } from './propagation.js'
import {
  buildUpstreamMap,
  computeCascadeDepthFromRoots,
  createRuntimeStates,
  snapshotFromRuntime,
  type SimulationConfig,
  type SimulationContext,
  type SimulationResult,
} from './types.js'
import type { SimulationEvent } from '../types/simulation.js'

const STABLE_TICKS_REQUIRED = 3

export function runSimulation(context: SimulationContext): SimulationResult {
  const { serviceIds, dependencies, disruptions, config } = context

  if (disruptions.length === 0) {
    throw new Error('At least one disruption is required to run a simulation.')
  }

  const runtimeStates = createRuntimeStates(serviceIds)
  const upstreamMap = buildUpstreamMap(dependencies)
  const events: SimulationEvent[] = []
  const snapshots = [snapshotFromRuntime(0, runtimeStates)]

  let stableTicks = 0
  let simulationTime = 0

  while (simulationTime < config.durationSeconds) {
    simulationTime += config.tickSeconds
    const changed = processSimulationTick(
      runtimeStates,
      upstreamMap,
      disruptions,
      simulationTime,
      events,
    )

    snapshots.push(snapshotFromRuntime(simulationTime, runtimeStates))

    if (changed) {
      stableTicks = 0
    } else {
      stableTicks += 1
    }

    if (stableTicks >= STABLE_TICKS_REQUIRED) {
      events.push({
        simulationTime,
        serviceId: disruptions[0].serviceId,
        eventType: 'STABILIZED',
        reason: 'No further state transitions detected',
      })
      break
    }
  }

  const affectedServices = Object.values(runtimeStates).filter(
    (runtime) =>
      runtime.firstAffectedTime !== null &&
      (runtime.state === 'DEGRADED' || runtime.state === 'FAILED'),
  )

  const cascadeDepth = computeCascadeDepthFromRoots(
    disruptions.map((disruption) => disruption.serviceId),
    dependencies,
    affectedServices.map((runtime) => runtime.id),
  )

  const finalStates = Object.fromEntries(
    Object.entries(runtimeStates).map(([id, runtime]) => [id, runtime.state]),
  )

  const firstDisruptionTime = Math.min(...disruptions.map((disruption) => disruption.startTime))

  return {
    events,
    snapshots,
    finalStates,
    runtimeStates,
    metrics: {
      affectedServices: affectedServices.length,
      cascadeDepth,
      recoveryTime: 0,
    },
    completedAt: simulationTime,
    firstDisruptionTime,
  }
}

export const DEFAULT_SIMULATION_CONFIG: SimulationConfig = {
  seed: 42003,
  durationSeconds: 60,
  tickSeconds: 1,
}

export function createPowerGridFailureScenario(serviceId = 'svc-power') {
  return {
    seed: 42003,
    disruptions: [{ serviceId, startTime: 0, severity: 1 }],
    config: DEFAULT_SIMULATION_CONFIG,
  }
}
