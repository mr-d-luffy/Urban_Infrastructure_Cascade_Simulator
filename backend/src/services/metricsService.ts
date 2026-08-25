import { deriveTimelineMarkers } from '../utils/timelineHelpers.js'
import type { SimulationMetrics, SimulationRecord } from '../types/simulation.js'

export function buildTimeline(simulation: SimulationRecord) {
  const markers = deriveTimelineMarkers(simulation.events)
  return {
    simulationTime: simulation.completedAt,
    markers,
    events: simulation.events,
  }
}

export function getSimulationMetrics(simulation: SimulationRecord): SimulationMetrics {
  return simulation.metrics
}
