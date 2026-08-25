import type { ServiceState } from '@/types/graph'

export type SimulationStatus = 'IDLE' | 'RUNNING' | 'COMPLETED' | 'FAILED'

export type SimulationEventType =
  | 'FAILURE'
  | 'DEGRADATION'
  | 'PROPAGATION'
  | 'RECOVERY_STARTED'
  | 'RECOVERY_COMPLETED'
  | 'STABILIZED'

export interface SimulationEvent {
  simulationTime: number
  serviceId: string
  eventType: SimulationEventType
  previousState?: ServiceState
  newState?: ServiceState
  reason?: string
}

export interface SimulationMetrics {
  affectedServices: number
  cascadeDepth: number
  recoveryTime: number
  impactPercentage: number
  criticalServicesAffected: number
  totalServices: number
}
