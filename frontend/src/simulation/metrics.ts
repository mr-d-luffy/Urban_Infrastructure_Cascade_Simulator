import type { Service } from '@/types/graph'
import type { SimulationEvent, SimulationMetrics } from '@/types/simulation'
import type { RecoverySimulationResult } from '@/simulation/recovery'
import type { SimulationResult } from '@/simulation/types'

const CRITICALITY_THRESHOLD = 4

const IMPACT_EVENT_TYPES = new Set(['FAILURE', 'DEGRADATION', 'PROPAGATION'])

function affectedServiceIdsFromEvents(events: SimulationEvent[]): Set<string> {
  const ids = new Set<string>()
  for (const event of events) {
    if (IMPACT_EVENT_TYPES.has(event.eventType)) {
      ids.add(event.serviceId)
    }
  }
  return ids
}

export function countCriticalAffected(
  services: Service[],
  affectedIds: Set<string>,
): number {
  return services.filter(
    (service) => service.criticality >= CRITICALITY_THRESHOLD && affectedIds.has(service.id),
  ).length
}

export function calculateMetrics(
  result: SimulationResult,
  services: Service[],
): SimulationMetrics {
  const affectedIds = affectedServiceIdsFromEvents(result.events)
  const totalServices = services.length
  const affectedServices = Math.max(result.metrics.affectedServices, affectedIds.size)
  const impactPercentage =
    totalServices === 0
      ? 0
      : Number(((affectedServices / totalServices) * 100).toFixed(1))

  return {
    affectedServices,
    cascadeDepth: result.metrics.cascadeDepth,
    recoveryTime: result.metrics.recoveryTime,
    impactPercentage,
    criticalServicesAffected: countCriticalAffected(services, affectedIds),
    totalServices,
  }
}

export function mergeRecoveryMetrics(
  base: SimulationMetrics,
  recovery: RecoverySimulationResult,
): SimulationMetrics {
  return {
    ...base,
    recoveryTime: recovery.recoveryTime,
  }
}

export function computeDisplayMetrics(
  base: SimulationMetrics | null,
  services: Service[],
  events: SimulationEvent[],
  phase: string,
): SimulationMetrics | null {
  if (!base) return null

  if (phase === 'complete') return base

  const currentlyImpacted = services.filter((service) =>
    ['DEGRADED', 'FAILED', 'RECOVERING'].includes(service.state),
  ).length

  const affectedIds = affectedServiceIdsFromEvents(events)

  return {
    ...base,
    affectedServices: Math.max(base.affectedServices, currentlyImpacted, affectedIds.size),
    criticalServicesAffected: Math.max(
      base.criticalServicesAffected,
      countCriticalAffected(services, affectedIds),
    ),
    impactPercentage:
      base.totalServices === 0
        ? 0
        : Number(
            (
              (Math.max(base.affectedServices, currentlyImpacted, affectedIds.size) /
                base.totalServices) *
              100
            ).toFixed(1),
          ),
  }
}

export function formatRecoveryTime(seconds: number): string {
  if (seconds <= 0) return '—'
  const minutes = Math.floor(seconds / 60)
  const remaining = seconds % 60
  if (minutes === 0) return `${remaining}s`
  return `${minutes}m ${remaining.toString().padStart(2, '0')}s`
}

export function formatMetricValue(value: number): string {
  return value.toString().padStart(2, '0')
}

export function buildRecoveryDurations(
  services: { id: string; criticality: number }[],
): Record<string, number> {
  return Object.fromEntries(
    services.map((service) => [
      service.id,
      Math.max(4, Math.min(10, service.criticality + 1)),
    ]),
  )
}
