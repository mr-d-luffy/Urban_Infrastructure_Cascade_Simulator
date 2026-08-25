import type { SimulationEvent } from '@/types/simulation'
import type { Service } from '@/types/graph'
import {
  activePhaseId,
  deriveTimelineMarkers,
  eventsForMarker,
  formatTimelineTime,
  getTimelineSpan,
  markerPosition,
  type TimelineMarker,
} from '@/utils/timelineHelpers'
import { useMemo, useState } from 'react'

const FRIENDLY_EVENT_TYPES: Record<string, string> = {
  FAILURE: 'Critical Failure',
  DEGRADATION: 'Service Degraded',
  PROPAGATION: 'Cascade Propagation',
  RECOVERY_STARTED: 'Recovery Started',
  RECOVERY_COMPLETED: 'Recovery Completed',
  STABILIZED: 'System Stabilized',
}

interface SimulationTimelineProps {
  events: SimulationEvent[]
  simulationTime: number
  services?: Service[]
}

export function SimulationTimeline({ events, simulationTime, services }: SimulationTimelineProps) {
  const [inspectedMarker, setInspectedMarker] = useState<TimelineMarker | null>(null)

  const markers = useMemo(() => deriveTimelineMarkers(events), [events])
  const span = useMemo(
    () => getTimelineSpan(markers, simulationTime),
    [markers, simulationTime],
  )
  const currentPhase = activePhaseId(markers, simulationTime)
  const inspectedEvents = inspectedMarker
    ? eventsForMarker(inspectedMarker, events)
    : []

  const serviceMap = useMemo(
    () => new Map(services?.map((s) => [s.id, s.name]) ?? []),
    [services],
  )

  const progressPosition = markerPosition(simulationTime, span)

  return (
    <div className="rounded-lg border border-navy/10 dark:border-white/10 bg-white dark:bg-[#132230] p-5">
      <div className="flex items-center justify-between gap-4">
        <h3 className="text-xs tracking-cinematic text-neutral dark:text-neutral/80">Timeline</h3>
        <p className="text-xs text-neutral dark:text-neutral/80">T+{formatTimelineTime(simulationTime)}</p>
      </div>

      {events.length === 0 ? (
        <p className="mt-6 text-sm text-neutral dark:text-neutral/80">
          Run a simulation to see failure, propagation, recovery, and stabilization phases.
        </p>
      ) : (
        <>
          <div className="relative mt-8 px-2">
            <div className="absolute left-2 right-2 top-1/2 h-px -translate-y-1/2 bg-navy/15 dark:bg-white/10" />

            <div
              className="absolute top-1/2 h-2 w-2 -translate-y-1/2 rounded-full bg-navy dark:bg-white shadow-sm"
              style={{ left: `calc(${progressPosition}% + 8px - ${progressPosition * 0.16}px)` }}
              aria-hidden="true"
            />

            <div className="relative flex justify-between gap-2">
              {markers.map((marker) => {
                const isActive = currentPhase === marker.id
                const isInspected = inspectedMarker?.id === marker.id
                const hasTime = marker.time !== null

                return (
                  <button
                    key={marker.id}
                    type="button"
                    disabled={!hasTime}
                    onClick={() => setInspectedMarker(isInspected ? null : marker)}
                    className={`group flex min-w-0 flex-1 flex-col items-center text-center transition-opacity ${
                      hasTime ? 'cursor-pointer' : 'cursor-default opacity-40'
                    }`}
                    aria-label={`${marker.label}${hasTime ? ` at T+${formatTimelineTime(marker.time!)}` : ''}`}
                  >
                    <span
                      className={`mb-3 inline-flex h-2.5 w-2.5 rounded-full border-2 border-white ${
                        isActive
                          ? 'bg-warning'
                          : isInspected
                            ? 'bg-navy dark:bg-white'
                            : hasTime
                              ? 'bg-neutral'
                              : 'bg-neutral/30'
                      }`}
                    />
                    <span
                      className={`text-[10px] tracking-cinematic ${
                        isActive ? 'text-navy dark:text-white' : 'text-neutral dark:text-neutral/60'
                      }`}
                    >
                      {marker.label}
                    </span>
                    <span className="mt-1 text-xs tabular-nums text-navy dark:text-white">
                      {hasTime ? formatTimelineTime(marker.time!) : '—'}
                    </span>
                  </button>
                )
              })}
            </div>
          </div>

          {inspectedMarker && (
            <div className="mt-6 rounded-md border border-navy/10 dark:border-white/10 bg-surface/60 dark:bg-navy/30 p-4">
              <p className="text-[10px] tracking-cinematic text-neutral dark:text-neutral/80">
                {inspectedMarker.label.toUpperCase()}
                {inspectedMarker.time !== null &&
                  ` · T+${formatTimelineTime(inspectedMarker.time)}`}
              </p>
              {inspectedEvents.length === 0 ? (
                <p className="mt-2 text-sm text-neutral dark:text-neutral/80">No detailed events for this phase.</p>
              ) : (
                <ul className="mt-3 space-y-2">
                  {inspectedEvents.slice(0, 5).map((event, index) => {
                    const name = serviceMap.get(event.serviceId) || event.serviceId
                    const friendlyType = FRIENDLY_EVENT_TYPES[event.eventType] || event.eventType
                    return (
                      <li key={`${event.serviceId}-${event.simulationTime}-${index}`} className="text-sm">
                        <span className="font-medium text-navy dark:text-white">{name}</span>
                        <span className="ml-2 text-neutral dark:text-neutral/60">{friendlyType}</span>
                        {event.previousState && event.newState && (
                          <span className="ml-2 text-xs font-mono text-neutral dark:text-neutral/60">
                            ({event.previousState} → {event.newState})
                          </span>
                        )}
                        {event.reason && (
                          <span className="mt-0.5 block text-xs text-neutral dark:text-neutral/60">{event.reason}</span>
                        )}
                      </li>
                    )
                  })}
                </ul>
              )}
            </div>
          )}

          <ul className="mt-6 max-h-40 space-y-2 overflow-y-auto border-t border-navy/10 dark:border-white/10 pt-4">
            {[...events].reverse().slice(0, 8).map((event, index) => {
              const name = serviceMap.get(event.serviceId) || event.serviceId
              const friendlyType = FRIENDLY_EVENT_TYPES[event.eventType] || event.eventType
              return (
                <li
                  key={`${event.simulationTime}-${event.serviceId}-${index}`}
                  className="flex items-start justify-between gap-3 text-sm animate-fade-in"
                >
                  <span className="text-navy dark:text-white font-medium">
                    {name} <span className="text-neutral dark:text-neutral/60 font-normal">· {friendlyType}</span>
                  </span>
                  <span className="text-right text-neutral dark:text-neutral/60 text-xs tabular-nums">
                    T+{formatTimelineTime(event.simulationTime)}
                    {event.newState && (
                      <span className="ml-2 text-xs font-semibold text-navy dark:text-white">{event.newState}</span>
                    )}
                  </span>
                </li>
              )
            })}
          </ul>
        </>
      )}
    </div>
  )
}
