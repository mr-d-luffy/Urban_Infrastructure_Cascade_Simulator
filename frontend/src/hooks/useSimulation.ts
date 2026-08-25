/* eslint-disable react-hooks/set-state-in-effect */
import { SEED_INFRASTRUCTURE } from '@/data/seedInfrastructure'
import {
  createPowerGridFailureScenario,
  DEFAULT_SIMULATION_CONFIG,
  runSimulation,
} from '@/simulation/engine'
import {
  buildRecoveryDurations,
  calculateMetrics,
  computeDisplayMetrics,
  formatRecoveryTime,
  mergeRecoveryMetrics,
} from '@/simulation/metrics'
import { runRecoverySimulation } from '@/simulation/recovery'
import type { Disruption, RecoveryAction, ServiceRuntime, SimulationSnapshot } from '@/simulation/types'
import type { Dependency, GraphData, Service, ServiceState } from '@/types/graph'
import type { SimulationEvent, SimulationMetrics, SimulationStatus } from '@/types/simulation'
import {
  getDownstreamDependents,
  getUpstreamDependencies,
} from '@/utils/graphHelpers'
import { useCallback, useEffect, useMemo, useRef, useState } from 'react'

const PLAYBACK_MS = 700

export type SimulationPhase = 'idle' | 'failure' | 'recovery' | 'complete'

function applyStatesToServices(services: Service[], states: Record<string, ServiceState>) {
  return services.map((service) => ({
    ...service,
    state: states[service.id] ?? service.state,
  }))
}

export function useSimulation(initialData: GraphData = SEED_INFRASTRUCTURE) {
  const initialServices = useMemo(() => initialData.services, [initialData.services])
  const recoveryDurations = useMemo(
    () => buildRecoveryDurations(initialServices),
    [initialServices],
  )

  const [services, setServices] = useState<Service[]>(initialServices)
  const [dependencies, setDependencies] = useState<Dependency[]>(initialData.dependencies)
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [disruptions, setDisruptions] = useState<Disruption[]>([])
  const [recoveryTargets, setRecoveryTargets] = useState<string[]>([])
  const [status, setStatus] = useState<SimulationStatus>('IDLE')
  const [phase, setPhase] = useState<SimulationPhase>('idle')
  const [simulationTime, setSimulationTime] = useState(0)
  const [events, setEvents] = useState<SimulationEvent[]>([])
  const [metrics, setMetrics] = useState<SimulationMetrics | null>(null)
  const [totalDuration, setTotalDuration] = useState(0)
  const [activeEdgeIds, setActiveEdgeIds] = useState<string[]>([])
  const [error, setError] = useState<string | null>(null)

  const playbackRef = useRef<number | null>(null)
  const runtimeStatesRef = useRef<Record<string, ServiceRuntime> | null>(null)
  const failureCompletedAtRef = useRef(0)
  const firstDisruptionTimeRef = useRef(0)

  const selectedService = useMemo(
    () => services.find((service) => service.id === selectedId) ?? null,
    [services, selectedId],
  )

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

  const recoverableServices = useMemo(
    () =>
      services.filter(
        (service) => service.state === 'FAILED' || service.state === 'DEGRADED',
      ),
    [services],
  )

  const displayMetrics = useMemo(
    () => computeDisplayMetrics(metrics, services, events, phase),
    [metrics, services, events, phase],
  )

  const stopPlayback = useCallback(() => {
    if (playbackRef.current !== null) {
      window.clearInterval(playbackRef.current)
      playbackRef.current = null
    }
  }, [])

  useEffect(() => stopPlayback, [stopPlayback])

  useEffect(() => {
    stopPlayback()
    setServices(initialServices)
    setDependencies(initialData.dependencies)
    setDisruptions([])
    setRecoveryTargets([])
    setStatus('IDLE')
    setPhase('idle')
    setEvents([])
    setMetrics(null)
  }, [initialData.dependencies, initialServices, stopPlayback])

  const selectService = useCallback(
    (id: string | null) => {
      if (status === 'RUNNING') return
      setSelectedId(id)
    },
    [status],
  )

  const toggleDisruption = useCallback(
    (serviceId: string) => {
      if (status === 'RUNNING' || phase === 'failure' || phase === 'recovery' || phase === 'complete')
        return

      setDisruptions((current) => {
        const exists = current.some((disruption) => disruption.serviceId === serviceId)
        if (exists) {
          return current.filter((disruption) => disruption.serviceId !== serviceId)
        }
        return [...current, { serviceId, startTime: 0, severity: 1 }]
      })
      setError(null)
    },
    [phase, status],
  )

  const toggleRecoveryTarget = useCallback(
    (serviceId: string) => {
      if (status === 'RUNNING') return

      setRecoveryTargets((current) => {
        if (current.includes(serviceId)) {
          return current.filter((id) => id !== serviceId)
        }
        return [...current, serviceId]
      })
      setError(null)
    },
    [status],
  )

  const loadDemoScenario = useCallback(() => {
    if (status === 'RUNNING') return
    const scenario = createPowerGridFailureScenario()
    setDisruptions(scenario.disruptions)
    setRecoveryTargets([])
    setSelectedId('svc-power')
    setPhase('idle')
    setError(null)
  }, [status])

  const resetSimulation = useCallback(() => {
    stopPlayback()
    setServices(initialServices)
    setDisruptions([])
    setRecoveryTargets([])
    setStatus('IDLE')
    setPhase('idle')
    setSimulationTime(0)
    setEvents([])
    setMetrics(null)
    setTotalDuration(0)
    setActiveEdgeIds([])
    setError(null)
    setSelectedId(null)
    runtimeStatesRef.current = null
    failureCompletedAtRef.current = 0
    firstDisruptionTimeRef.current = 0
  }, [initialServices, stopPlayback])

  const loadScenario = useCallback((nextDisruptions: Disruption[]) => {
    if (status === 'RUNNING') return
    resetSimulation()
    setDisruptions(nextDisruptions)
  }, [resetSimulation, status])

  const highlightPropagationEdges = useCallback(
    (snapshotEvents: SimulationEvent[]) => {
      const latest = snapshotEvents.at(-1)
      if (!latest) {
        setActiveEdgeIds([])
        return
      }

      const related = dependencies
        .filter((dep) => dep.targetServiceId === latest.serviceId)
        .map((dep) => dep.id)

      setActiveEdgeIds(related)
      window.setTimeout(() => setActiveEdgeIds([]), PLAYBACK_MS - 100)
    },
    [dependencies],
  )

  const playSnapshots = useCallback(
    (
      snapshots: SimulationSnapshot[],
      resultEvents: SimulationEvent[],
      onComplete: () => void,
    ) => {
      let frame = 0

      playbackRef.current = window.setInterval(() => {
        const snapshot = snapshots[frame]
        if (!snapshot) return

        setSimulationTime(snapshot.simulationTime)
        setServices((current) => applyStatesToServices(current, snapshot.states))

        const tickEvents = resultEvents.filter(
          (event) => event.simulationTime === snapshot.simulationTime,
        )
        if (tickEvents.length > 0) {
          setEvents((current) => [...current, ...tickEvents])
          highlightPropagationEdges(tickEvents)
        }

        frame += 1

        if (frame >= snapshots.length) {
          stopPlayback()
          onComplete()
          setActiveEdgeIds([])
        }
      }, PLAYBACK_MS)
    },
    [highlightPropagationEdges, stopPlayback],
  )

  const runSimulationPlayback = useCallback(
    (reducedMotion: boolean) => {
      if (disruptions.length === 0) {
        setError('Select at least one service to disrupt before running.')
        return
      }

      try {
        stopPlayback()
        setError(null)
        setEvents([])
        setMetrics(null)
        setRecoveryTargets([])
        setStatus('RUNNING')
        setPhase('failure')
        setSimulationTime(0)
        setServices(initialServices)

        const result = runSimulation({
          serviceIds: initialServices.map((service) => service.id),
          dependencies,
          disruptions,
          config: DEFAULT_SIMULATION_CONFIG,
          recoveryDurations,
        })

        runtimeStatesRef.current = result.runtimeStates
        failureCompletedAtRef.current = result.completedAt
        firstDisruptionTimeRef.current = result.firstDisruptionTime

        const nextMetrics = calculateMetrics(result, initialServices)
        setMetrics(nextMetrics)
        setTotalDuration(result.completedAt)

        const finishFailure = () => {
          setStatus('COMPLETED')
          setPhase('failure')
          setRecoveryTargets(
            Object.entries(result.finalStates)
              .filter(([, state]) => state === 'FAILED' || state === 'DEGRADED')
              .map(([id]) => id),
          )
        }

        if (reducedMotion) {
          const finalSnapshot = result.snapshots.at(-1)
          if (finalSnapshot) {
            setServices(applyStatesToServices(initialServices, finalSnapshot.states))
            setSimulationTime(finalSnapshot.simulationTime)
          }
          setEvents(result.events)
          finishFailure()
          return
        }

        playSnapshots(result.snapshots, result.events, finishFailure)
      } catch (runError) {
        setStatus('FAILED')
        setPhase('idle')
        setError(runError instanceof Error ? runError.message : 'Simulation failed.')
        stopPlayback()
      }
    },
    [dependencies, disruptions, initialServices, playSnapshots, recoveryDurations, stopPlayback],
  )

  const runRecoveryPlayback = useCallback(
    (reducedMotion: boolean) => {
      if (!runtimeStatesRef.current) {
        setError('Run the failure simulation before starting recovery.')
        return
      }

      if (recoveryTargets.length === 0) {
        setError('Select at least one service to recover.')
        return
      }

      try {
        stopPlayback()
        setError(null)
        setStatus('RUNNING')
        setPhase('recovery')

        const recoveryActions: RecoveryAction[] = recoveryTargets.map((serviceId) => ({
          serviceId,
          startTime: failureCompletedAtRef.current + DEFAULT_SIMULATION_CONFIG.tickSeconds,
        }))

        const result = runRecoverySimulation({
          runtimeStates: runtimeStatesRef.current,
          dependencies,
          recoveryActions,
          recoveryDurations,
          config: { ...DEFAULT_SIMULATION_CONFIG, durationSeconds: 90 },
          startTime: failureCompletedAtRef.current,
          firstDisruptionTime: firstDisruptionTimeRef.current,
        })

        runtimeStatesRef.current = Object.fromEntries(
          Object.entries(result.finalStates).map(([id, state]) => [
            id,
            {
              ...(runtimeStatesRef.current?.[id] ?? {
                id,
                stress: 0,
                disrupted: false,
                firstAffectedTime: null,
                recoveryTicksRemaining: null,
              }),
              state,
              recoveryTicksRemaining: null,
            },
          ]),
        )

        setMetrics((current) =>
          current
            ? mergeRecoveryMetrics(current, result)
            : {
                affectedServices: 0,
                cascadeDepth: 0,
                recoveryTime: result.recoveryTime,
                impactPercentage: 0,
                criticalServicesAffected: 0,
                totalServices: initialServices.length,
              },
        )
        setTotalDuration(result.completedAt)

        const finishRecovery = () => {
          setStatus('COMPLETED')
          setPhase('complete')
          setRecoveryTargets([])
        }

        if (reducedMotion) {
          const finalSnapshot = result.snapshots.at(-1)
          if (finalSnapshot) {
            setServices((current) =>
              applyStatesToServices(current, finalSnapshot.states),
            )
            setSimulationTime(finalSnapshot.simulationTime)
          }
          setEvents((current) => [...current, ...result.events])
          finishRecovery()
          return
        }

        playSnapshots(result.snapshots, result.events, finishRecovery)
      } catch (runError) {
        setStatus('FAILED')
        setError(runError instanceof Error ? runError.message : 'Recovery failed.')
        stopPlayback()
      }
    },
    [dependencies, initialServices.length, playSnapshots, recoveryDurations, recoveryTargets, stopPlayback],
  )

  return {
    services,
    dependencies,
    selectedService,
    selectedId,
    selectService,
    upstream,
    downstream,
    disruptions,
    recoveryTargets,
    recoverableServices,
    toggleDisruption,
    toggleRecoveryTarget,
    loadDemoScenario,
    loadScenario,
    status,
    phase,
    simulationTime,
    events,
    metrics: displayMetrics,
    totalDuration,
    activeEdgeIds,
    error,
    formatRecoveryTime,
    runSimulation: runSimulationPlayback,
    runRecovery: runRecoveryPlayback,
    resetSimulation,
  }
}

export type UseSimulationReturn = ReturnType<typeof useSimulation>
