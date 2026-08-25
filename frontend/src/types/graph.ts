export type ServiceState =
  | 'HEALTHY'
  | 'DEGRADED'
  | 'FAILED'
  | 'RECOVERING'
  | 'RECOVERED'

export interface Service {
  id: string
  name: string
  slug: string
  category: string
  criticality: number
  state: ServiceState
  description?: string
  position?: { x: number; y: number }
}

export interface Dependency {
  id: string
  sourceServiceId: string
  targetServiceId: string
  dependencyStrength: number
}

export interface GraphData {
  services: Service[]
  dependencies: Dependency[]
}
