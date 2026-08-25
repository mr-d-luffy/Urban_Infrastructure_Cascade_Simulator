import type { GraphData, ServiceState } from '@/types/graph'

export const SERVICE_STATES: ServiceState[] = [
  'HEALTHY',
  'DEGRADED',
  'FAILED',
  'RECOVERING',
  'RECOVERED',
]

export const STATE_STYLES: Record<
  ServiceState,
  { dot: string; border: string; label: string }
> = {
  HEALTHY: {
    dot: 'bg-success',
    border: 'border-success/30',
    label: 'text-success',
  },
  DEGRADED: {
    dot: 'bg-degraded',
    border: 'border-degraded/40',
    label: 'text-degraded',
  },
  FAILED: {
    dot: 'bg-critical',
    border: 'border-critical/40',
    label: 'text-critical',
  },
  RECOVERING: {
    dot: 'bg-warning',
    border: 'border-warning/40',
    label: 'text-warning',
  },
  RECOVERED: {
    dot: 'bg-success',
    border: 'border-success/30',
    label: 'text-success',
  },
}

export function getServiceById(services: GraphData['services'], id: string) {
  return services.find((service) => service.id === id)
}

export function getUpstreamDependencies(
  dependencies: GraphData['dependencies'],
  services: GraphData['services'],
  serviceId: string,
) {
  return dependencies
    .filter((dep) => dep.targetServiceId === serviceId)
    .map((dep) => getServiceById(services, dep.sourceServiceId))
    .filter((service): service is NonNullable<typeof service> => Boolean(service))
}

export function getDownstreamDependents(
  dependencies: GraphData['dependencies'],
  services: GraphData['services'],
  serviceId: string,
) {
  return dependencies
    .filter((dep) => dep.sourceServiceId === serviceId)
    .map((dep) => getServiceById(services, dep.targetServiceId))
    .filter((service): service is NonNullable<typeof service> => Boolean(service))
}
