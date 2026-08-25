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
  defaultState: ServiceState
  description?: string
  recoveryDuration: number
  createdAt: string
  updatedAt: string
}

export interface Dependency {
  id: string
  sourceServiceId: string
  targetServiceId: string
  dependencyStrength: number
  dependencyType: string
  failureThreshold: number
  createdAt: string
}
