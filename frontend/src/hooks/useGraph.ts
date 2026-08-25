import { SEED_INFRASTRUCTURE } from '@/data/seedInfrastructure'
import type { GraphData, Service, ServiceState } from '@/types/graph'
import {
  getDownstreamDependents,
  getUpstreamDependencies,
} from '@/utils/graphHelpers'
import { useCallback, useMemo, useState } from 'react'

export function useGraph(initialData: GraphData = SEED_INFRASTRUCTURE) {
  const [services, setServices] = useState<Service[]>(initialData.services)
  const [dependencies] = useState(initialData.dependencies)
  const [selectedId, setSelectedId] = useState<string | null>(null)

  const selectedService = useMemo(
    () => services.find((service) => service.id === selectedId) ?? null,
    [services, selectedId],
  )

  const selectService = useCallback((id: string | null) => {
    setSelectedId(id)
  }, [])

  const updateServiceState = useCallback((id: string, state: ServiceState) => {
    setServices((current) =>
      current.map((service) => (service.id === id ? { ...service, state } : service)),
    )
  }, [])

  const resetGraph = useCallback(() => {
    setServices(initialData.services)
    setSelectedId(null)
  }, [initialData.services])

  const upstream = useMemo(
    () =>
      selectedId
        ? getUpstreamDependencies(dependencies, services, selectedId)
        : [],
    [dependencies, selectedId, services],
  )

  const downstream = useMemo(
    () =>
      selectedId ? getDownstreamDependents(dependencies, services, selectedId) : [],
    [dependencies, selectedId, services],
  )

  return {
    services,
    dependencies,
    selectedService,
    selectedId,
    selectService,
    updateServiceState,
    resetGraph,
    upstream,
    downstream,
  }
}

export type UseGraphReturn = ReturnType<typeof useGraph>
