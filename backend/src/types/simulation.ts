import type { ServiceState } from './graph.js'

export type SimulationStatus = 'QUEUED' | 'RUNNING' | 'COMPLETED' | 'FAILED' | 'CANCELLED'

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

export interface SimulationRecord {
  id: string
  scenarioId: string | null
  status: SimulationStatus
  disruptions: Array<{
    serviceId: string
    startTime: number
    severity: number
    duration?: number
  }>
  events: SimulationEvent[]
  metrics: SimulationMetrics
  finalStates: Record<string, ServiceState>
  completedAt: number
  firstDisruptionTime: number
  startedAt: string
  completedAtTs: string | null
}
