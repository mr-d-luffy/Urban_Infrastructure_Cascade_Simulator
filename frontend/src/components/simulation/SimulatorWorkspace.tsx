import { InfrastructureGraph } from '@/components/graph/InfrastructureGraph'
import { ServiceDetailsPanel } from '@/components/graph/ServiceDetailsPanel'
import { MetricCards } from '@/components/metrics/MetricCards'
import { SimulationProgress } from '@/components/metrics/SimulationProgress'
import { SimulationControls } from '@/components/simulation/SimulationControls'
import { SimulationTimeline } from '@/components/simulation/SimulationTimeline'
import { ScenarioManager } from '@/components/simulation/ScenarioManager'
import { SEED_INFRASTRUCTURE } from '@/data/seedInfrastructure'
import { usePrefersReducedMotion } from '@/hooks/useVideoScrub'
import { useSimulation } from '@/hooks/useSimulation'
import { api } from '@/services/api'
import type { GraphData } from '@/types/graph'
import { useEffect, useState } from 'react'

export function SimulatorWorkspace() {
  const reducedMotion = usePrefersReducedMotion()
  const [graphData, setGraphData] = useState<GraphData>(SEED_INFRASTRUCTURE)
  const [connectionState, setConnectionState] = useState<'checking' | 'postgres' | 'memory' | 'offline'>('checking')

  useEffect(() => {
    api.health()
      .then((res) => {
        if (res.success && res.data) {
          setConnectionState(res.data.databaseConnected ? 'postgres' : 'memory')
        } else {
          setConnectionState('offline')
        }
      })
      .catch(() => {
        setConnectionState('offline')
      })

    void Promise.all([api.getServices(), api.getDependencies()]).then(([services, dependencies]) => {
      if (!services.success || !services.data || !dependencies.success || !dependencies.data) return
      const positions = new Map(SEED_INFRASTRUCTURE.services.map((service) => [service.slug, service.position]))
      setGraphData({
        services: services.data.map((service) => ({ ...service, state: 'HEALTHY' as const, position: positions.get(service.slug) })),
        dependencies: dependencies.data,
      })
    })
  }, [])
  const {
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
    metrics,
    totalDuration,
    activeEdgeIds,
    error,
    runSimulation,
    runRecovery,
    resetSimulation,
  } = useSimulation(graphData)

  const failedCount = services.filter((service) => service.state === 'FAILED').length
  const recoveringCount = services.filter((service) => service.state === 'RECOVERING').length
  const healthyCount = services.filter((service) => service.state === 'HEALTHY').length

  return (
    <section
      id="simulator"
      className="min-h-screen border-t border-navy/10 dark:border-white/10 bg-surface dark:bg-[#0B131C] px-6 py-24 transition-colors"
      aria-label="Simulator"
    >
      <div className="mx-auto max-w-7xl">
        <div className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div className="max-w-2xl">
            <div className="flex flex-wrap items-center gap-3">
              <p className="text-xs tracking-cinematic text-neutral dark:text-neutral/80">INFRASTRUCTURE SIMULATOR</p>
              <span className={`inline-flex items-center gap-1.5 rounded-full px-2 py-0.5 text-[10px] font-medium border ${
                connectionState === 'postgres' ? 'bg-success/10 border-success/30 text-success' :
                connectionState === 'memory' ? 'bg-warning/10 border-warning/30 text-warning' :
                connectionState === 'checking' ? 'bg-neutral/10 border-neutral/30 text-neutral' :
                'bg-critical/10 border-critical/30 text-critical'
              }`}>
                <span className={`h-1.5 w-1.5 rounded-full ${
                  connectionState === 'postgres' ? 'bg-success' :
                  connectionState === 'memory' ? 'bg-warning' :
                  connectionState === 'checking' ? 'bg-neutral animate-pulse' :
                  'bg-critical'
                }`} />
                {connectionState === 'postgres' ? 'POSTGRESQL CONNECTED' :
                 connectionState === 'memory' ? 'IN-MEMORY FALLBACK' :
                 connectionState === 'checking' ? 'CHECKING CONNECTION...' :
                 'OFFLINE FALLBACK'}
              </span>
            </div>
            <h2 className="mt-3 text-3xl font-light tracking-wide text-navy dark:text-white sm:text-4xl">
              Cascade analytics
            </h2>
            <p className="mt-4 text-neutral dark:text-neutral/80">
              Run simulations, inspect cascade metrics, and follow the timeline from failure
              through propagation, recovery, and stabilization.
            </p>
          </div>
          <p className="text-sm text-neutral dark:text-slate-300">
            {healthyCount} healthy · {failedCount} failed · {recoveringCount} recovering · T+
            {simulationTime}s
          </p>
        </div>

        <div className="grid grid-cols-1 gap-6 lg:grid-cols-[1fr_2fr_1fr]">
          <div className="order-2 lg:order-none lg:col-span-3 lg:row-start-1">
            <MetricCards metrics={metrics} phase={phase} />
          </div>

          <aside className="space-y-4 order-3 lg:order-none lg:col-start-1 lg:row-start-2">
            <SimulationControls
              services={services}
              disruptions={disruptions}
              recoveryTargets={recoveryTargets}
              recoverableServices={recoverableServices}
              selectedId={selectedId}
              status={status}
              phase={phase}
              simulationTime={simulationTime}
              metrics={metrics}
              error={error}
              onToggleDisruption={toggleDisruption}
              onToggleRecoveryTarget={toggleRecoveryTarget}
              onLoadDemo={loadDemoScenario}
              onRun={() => runSimulation(reducedMotion)}
              onRecover={() => runRecovery(reducedMotion)}
              onReset={resetSimulation}
            />

            <ScenarioManager
              disruptions={disruptions}
              disabled={status === 'RUNNING'}
              onLoad={loadScenario}
            />

            <div className="rounded-lg border border-navy/10 dark:border-white/10 bg-white dark:bg-[#132230] p-5">
              <h3 className="text-xs tracking-cinematic text-neutral dark:text-neutral/80">Legend</h3>
              <ul className="mt-4 space-y-2 text-xs">
                {[
                  { state: 'HEALTHY', color: 'bg-success' },
                  { state: 'DEGRADED', color: 'bg-degraded' },
                  { state: 'FAILED', color: 'bg-critical' },
                  { state: 'RECOVERING', color: 'bg-warning' },
                  { state: 'RECOVERED', color: 'bg-success' },
                ].map((item) => (
                  <li key={item.state} className="flex items-center gap-2 text-navy dark:text-white">
                    <span className={`h-2 w-2 rounded-full ${item.color}`} />
                    {item.state}
                  </li>
                ))}
              </ul>
            </div>
          </aside>

          <div className="h-[min(70vh,640px)] overflow-hidden rounded-lg border border-navy/10 bg-white order-1 lg:order-none lg:col-start-2 lg:row-start-2">
            <InfrastructureGraph
              services={services}
              dependencies={dependencies}
              selectedId={selectedId}
              activeEdgeIds={activeEdgeIds}
              onSelectService={selectService}
            />
          </div>

          <aside className="space-y-4 order-4 lg:order-none lg:col-start-3 lg:row-start-2">
            {selectedService ? (
              <ServiceDetailsPanel
                service={selectedService}
                upstream={upstream}
                downstream={downstream}
                onClose={() => selectService(null)}
                onSelectService={selectService}
              />
            ) : (
              <div className="rounded-lg border border-dashed border-navy/15 dark:border-white/10 bg-white dark:bg-[#132230] p-5">
                <p className="text-[10px] tracking-cinematic text-neutral dark:text-neutral/80">SERVICE DETAILS</p>
                <p className="mt-3 text-sm text-neutral dark:text-neutral/80">
                  Select a service on the graph to inspect dependencies and current status.
                </p>
              </div>
            )}

            <SimulationProgress
              simulationTime={simulationTime}
              totalDuration={totalDuration}
              phase={phase}
              status={status}
            />
          </aside>

          <div className="order-5 lg:order-none lg:col-span-3 lg:row-start-3">
            <SimulationTimeline events={events} simulationTime={simulationTime} services={services} />
          </div>
        </div>
      </div>
    </section>
  )
}
