import type { SimulationEvent } from '@/types/simulation'

export type TimelinePhaseId = 'failure' | 'propagation' | 'recovery' | 'stable'

export interface TimelineMarker {
  id: TimelinePhaseId
  label: string
  time: number | null
}

export interface TimelineInspection {
  marker: TimelineMarker
  events: SimulationEvent[]
}

export function formatTimelineTime(seconds: number): string {
  const minutes = Math.floor(seconds / 60)
  const remaining = seconds % 60
  return `${minutes.toString().padStart(2, '0')}:${remaining.toString().padStart(2, '0')}`
}

export function deriveTimelineMarkers(events: SimulationEvent[]): TimelineMarker[] {
  const failureEvent = events.find(
    (event) =>
      event.eventType === 'FAILURE' &&
      event.reason?.toLowerCase().includes('disruption'),
  )

  const propagationEvent = events.find(
    (event) =>
      event.eventType === 'PROPAGATION' ||
      (event.eventType === 'DEGRADATION' &&
        !event.reason?.toLowerCase().includes('disruption')),
  )

  const recoveryEvent = events.find((event) => event.eventType === 'RECOVERY_STARTED')

  const stableEvent = [...events].reverse().find((event) => event.eventType === 'STABILIZED')

  return [
    { id: 'failure', label: 'Failure', time: failureEvent?.simulationTime ?? null },
    {
      id: 'propagation',
      label: 'Propagation',
      time: propagationEvent?.simulationTime ?? null,
    },
    { id: 'recovery', label: 'Recovery', time: recoveryEvent?.simulationTime ?? null },
    { id: 'stable', label: 'Stable', time: stableEvent?.simulationTime ?? null },
  ]
}

export function getTimelineSpan(markers: TimelineMarker[], simulationTime: number): number {
  const markerTimes = markers
    .map((marker) => marker.time)
    .filter((time): time is number => time !== null)

  const maxTime = Math.max(simulationTime, ...markerTimes, 0)
  return maxTime > 0 ? maxTime : 1
}

export function markerPosition(time: number | null, span: number): number {
  if (time === null || span <= 0) return 0
  return Math.min(Math.max((time / span) * 100, 0), 100)
}

export function eventsForMarker(
  marker: TimelineMarker,
  events: SimulationEvent[],
): SimulationEvent[] {
  if (marker.time === null) return []

  switch (marker.id) {
    case 'failure':
      return events.filter(
        (event) =>
          event.simulationTime === marker.time &&
          (event.eventType === 'FAILURE' || event.eventType === 'DEGRADATION'),
      )
    case 'propagation':
      return events.filter(
        (event) =>
          event.simulationTime === marker.time &&
          (event.eventType === 'PROPAGATION' || event.eventType === 'DEGRADATION'),
      )
    case 'recovery':
      return events.filter(
        (event) =>
          event.simulationTime >= marker.time! &&
          (event.eventType === 'RECOVERY_STARTED' ||
            event.eventType === 'RECOVERY_COMPLETED'),
      )
    case 'stable':
      return events.filter(
        (event) => event.simulationTime === marker.time && event.eventType === 'STABILIZED',
      )
    default:
      return []
  }
}

export function activePhaseId(
  markers: TimelineMarker[],
  simulationTime: number,
): TimelinePhaseId | null {
  const ordered = markers.filter((marker) => marker.time !== null)
  if (ordered.length === 0) return null

  let active: TimelinePhaseId | null = ordered[0]?.id ?? null
  for (const marker of ordered) {
    if (marker.time !== null && simulationTime >= marker.time) {
      active = marker.id
    }
  }
  return active
}
