import type { Dependency, ServiceState } from '@/types/graph'
import type { SimulationEvent, SimulationEventType } from '@/types/simulation'

export interface Disruption {
  serviceId: string
  startTime: number
  severity: number
  duration?: number
}

export interface RecoveryAction {
  serviceId: string
  startTime: number
}

export interface SimulationConfig {
  seed: number
  durationSeconds: number
  tickSeconds: number
}

export interface ServiceRuntime {
  id: string
  state: ServiceState
  stress: number
  disrupted: boolean
  firstAffectedTime: number | null
  recoveryTicksRemaining: number | null
}

export interface SimulationSnapshot {
  simulationTime: number
  states: Record<string, ServiceState>
  stress: Record<string, number>
}

export interface SimulationResult {
  events: SimulationEvent[]
  snapshots: SimulationSnapshot[]
  finalStates: Record<string, ServiceState>
  runtimeStates: Record<string, ServiceRuntime>
  metrics: {
    affectedServices: number
    cascadeDepth: number
    recoveryTime: number
  }
  completedAt: number
  firstDisruptionTime: number
}

export interface SimulationContext {
  serviceIds: string[]
  dependencies: Dependency[]
  disruptions: Disruption[]
  config: SimulationConfig
  recoveryDurations?: Record<string, number>
}

export function cloneRuntimeStates(
  runtimeStates: Record<string, ServiceRuntime>,
): Record<string, ServiceRuntime> {
  return Object.fromEntries(
    Object.entries(runtimeStates).map(([id, runtime]) => [id, { ...runtime }]),
  )
}

export function createRuntimeStates(serviceIds: string[]): Record<string, ServiceRuntime> {
  return Object.fromEntries(
    serviceIds.map((id) => [
      id,
      {
        id,
        state: 'HEALTHY' as ServiceState,
        stress: 0,
        disrupted: false,
        firstAffectedTime: null,
        recoveryTicksRemaining: null,
      },
    ]),
  )
}

export function buildDownstreamMap(dependencies: Dependency[]): Map<string, string[]> {
  const map = new Map<string, string[]>()
  for (const dep of dependencies) {
    const list = map.get(dep.sourceServiceId) ?? []
    list.push(dep.targetServiceId)
    map.set(dep.sourceServiceId, list)
  }
  return map
}

export function buildUpstreamMap(dependencies: Dependency[]): Map<string, Dependency[]> {
  const map = new Map<string, Dependency[]>()
  for (const dep of dependencies) {
    const list = map.get(dep.targetServiceId) ?? []
    list.push(dep)
    map.set(dep.targetServiceId, list)
  }
  return map
}

export function eventTypeForTransition(
  previous: ServiceState,
  next: ServiceState,
): SimulationEventType {
  if (next === 'FAILED') return previous === 'HEALTHY' ? 'FAILURE' : 'PROPAGATION'
  if (next === 'DEGRADED') return 'DEGRADATION'
  return 'PROPAGATION'
}

export function markAffected(
  runtime: ServiceRuntime,
  simulationTime: number,
  nextState: ServiceState,
) {
  if (
    runtime.firstAffectedTime === null &&
    (nextState === 'DEGRADED' || nextState === 'FAILED')
  ) {
    runtime.firstAffectedTime = simulationTime
  }
}

export function snapshotFromRuntime(
  simulationTime: number,
  runtimeStates: Record<string, ServiceRuntime>,
): SimulationSnapshot {
  const states: Record<string, ServiceState> = {}
  const stress: Record<string, number> = {}
  for (const [id, runtime] of Object.entries(runtimeStates)) {
    states[id] = runtime.state
    stress[id] = runtime.stress
  }
  return { simulationTime, states, stress }
}

export function computeCascadeDepthFromRoots(
  roots: string[],
  dependencies: Dependency[],
  affectedServiceIds: string[],
): number {
  if (affectedServiceIds.length === 0) return 0

  const downstream = buildDownstreamMap(dependencies)
  const depths = new Map<string, number>()
  const queue = roots.map((root) => ({ id: root, depth: 0 }))

  for (const root of roots) {
    depths.set(root, 0)
  }

  while (queue.length > 0) {
    const current = queue.shift()
    if (!current) break

    const neighbors = downstream.get(current.id) ?? []
    for (const neighbor of neighbors) {
      const nextDepth = current.depth + 1
      const existing = depths.get(neighbor)
      if (existing === undefined || nextDepth < existing) {
        depths.set(neighbor, nextDepth)
        queue.push({ id: neighbor, depth: nextDepth })
      }
    }
  }

  let maxDepth = 0
  for (const serviceId of affectedServiceIds) {
    const depth = depths.get(serviceId) ?? 0
    maxDepth = Math.max(maxDepth, depth)
  }

  return maxDepth
}
