import type { Disruption } from '@/simulation/types'
import type { Service } from '@/types/graph'
import type { SimulationMetrics, SimulationStatus } from '@/types/simulation'
import type { SimulationPhase } from '@/hooks/useSimulation'
import { Activity, ArrowRight, RotateCcw, Timer, Zap } from 'lucide-react'

interface SimulationControlsProps {
  services: Service[]
  disruptions: Disruption[]
  recoveryTargets: string[]
  recoverableServices: Service[]
  selectedId: string | null
  status: SimulationStatus
  phase: SimulationPhase
  simulationTime: number
  metrics: SimulationMetrics | null
  error: string | null
  onToggleDisruption: (serviceId: string) => void
  onToggleRecoveryTarget: (serviceId: string) => void
  onLoadDemo: () => void
  onRun: () => void
  onRecover: () => void
  onReset: () => void
}

export function SimulationControls({
  services,
  disruptions,
  recoveryTargets,
  recoverableServices,
  selectedId,
  status,
  phase,
  simulationTime,
  metrics,
  error,
  onToggleDisruption,
  onToggleRecoveryTarget,
  onLoadDemo,
  onRun,
  onRecover,
  onReset,
}: SimulationControlsProps) {
  const isRunning = status === 'RUNNING'
  const canRun = disruptions.length > 0 && !isRunning && phase === 'idle'
  const canRecover =
    recoveryTargets.length > 0 &&
    !isRunning &&
    (phase === 'failure' || phase === 'complete') &&
    recoverableServices.length > 0

  return (
    <div className="space-y-4">
      <div className="rounded-lg border border-navy/10 dark:border-white/10 bg-white dark:bg-[#132230] p-5">
        <h3 className="text-xs tracking-cinematic text-neutral dark:text-neutral/80">Simulation</h3>

        <div className="mt-4 flex flex-wrap gap-2">
          <button
            type="button"
            onClick={onLoadDemo}
            disabled={isRunning}
            aria-label="Load city power grid failure demonstration scenario"
            className="rounded-md border border-navy/15 dark:border-white/20 px-3 py-2 text-xs tracking-wide text-navy dark:text-white transition-colors hover:bg-surface dark:hover:bg-navy/40 disabled:opacity-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy focus-visible:ring-offset-2"
          >
            Load power failure demo
          </button>
          <button
            type="button"
            onClick={onRun}
            disabled={!canRun}
            aria-label="Run cascade simulation"
            className="inline-flex items-center gap-2 rounded-md bg-navy dark:bg-white px-4 py-2 text-xs font-medium tracking-wide text-white dark:text-navy transition-opacity hover:opacity-90 disabled:opacity-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy dark:focus-visible:ring-white focus-visible:ring-offset-2"
          >
            {isRunning && phase === 'failure' ? 'Running…' : 'Run simulation'}
            <ArrowRight className="h-3.5 w-3.5" aria-hidden="true" />
          </button>
          <button
            type="button"
            onClick={onRecover}
            disabled={!canRecover}
            aria-label="Start recovery simulation for selected targets"
            className="inline-flex items-center gap-2 rounded-md border border-success/30 dark:border-success/50 bg-success/10 dark:bg-success/20 px-4 py-2 text-xs font-medium tracking-wide text-navy dark:text-white transition-colors hover:bg-success/15 disabled:opacity-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-success focus-visible:ring-offset-2"
          >
            {isRunning && phase === 'recovery' ? 'Recovering…' : 'Start recovery'}
            <Timer className="h-3.5 w-3.5" aria-hidden="true" />
          </button>
          <button
            type="button"
            onClick={onReset}
            disabled={isRunning}
            aria-label="Reset simulation to initial state"
            className="inline-flex items-center gap-2 rounded-md border border-navy/15 dark:border-white/20 px-3 py-2 text-xs tracking-wide text-navy dark:text-white transition-colors hover:bg-surface dark:hover:bg-navy/40 disabled:opacity-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy focus-visible:ring-offset-2"
          >
            <RotateCcw className="h-3.5 w-3.5" aria-hidden="true" />
            Reset
          </button>
        </div>

        <p className="mt-4 text-xs text-neutral dark:text-slate-300">
          T+{simulationTime}s · {phase} · {status.toLowerCase()}
        </p>

        {error && (
          <p className="mt-3 text-sm text-critical" role="alert">
            {error}
          </p>
        )}

        {metrics && (
          <p className="mt-3 text-xs text-neutral">
            {metrics.criticalServicesAffected > 0 &&
              `${metrics.criticalServicesAffected} critical services affected · `}
            Impact {metrics.impactPercentage}%
          </p>
        )}
      </div>

      {phase === 'idle' && (
        <div className="rounded-lg border border-navy/10 dark:border-white/10 bg-white dark:bg-[#132230] p-5">
          <div className="flex items-center justify-between">
            <h3 className="text-xs tracking-cinematic text-neutral dark:text-neutral/80">Disruptions</h3>
            <span className="text-xs text-neutral dark:text-neutral/80">{disruptions.length} selected</span>
          </div>

          <p className="mt-2 text-xs text-neutral dark:text-neutral/80">
            Select services to fail at T+0. Multiple simultaneous disruptions are supported.
          </p>

          <ul className="mt-4 max-h-64 space-y-2 overflow-y-auto">
            {services.map((service) => {
              const selected = disruptions.some(
                (disruption) => disruption.serviceId === service.id,
              )
              const isFocused = selectedId === service.id

               return (
                <li key={service.id}>
                  <button
                    type="button"
                    disabled={isRunning}
                    onClick={() => onToggleDisruption(service.id)}
                    aria-pressed={selected}
                    aria-label={`Toggle disruption scenario for ${service.name}`}
                    className={`flex w-full items-center justify-between rounded-md border px-3 py-2 text-left text-sm transition-colors disabled:opacity-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy dark:focus-visible:ring-white focus-visible:ring-offset-2 ${
                      selected
                        ? 'border-critical/30 bg-critical/5 text-navy dark:border-critical/50 dark:bg-critical/10 dark:text-white'
                        : isFocused
                          ? 'border-navy/20 bg-surface text-navy dark:border-white/20 dark:bg-navy/40 dark:text-white'
                          : 'border-navy/10 dark:border-white/10 text-navy dark:text-white hover:bg-surface dark:hover:bg-navy/40'
                    }`}
                  >
                    <span>{service.name}</span>
                    {selected ? (
                      <Zap className="h-4 w-4 text-critical" aria-hidden="true" />
                    ) : (
                      <Activity className="h-4 w-4 text-neutral/40 dark:text-neutral/60" aria-hidden="true" />
                    )}
                  </button>
                </li>
              )
            })}
          </ul>
        </div>
      )}

      {(phase === 'failure' || phase === 'recovery' || phase === 'complete') && (
        <div className="rounded-lg border border-navy/10 dark:border-white/10 bg-white dark:bg-[#132230] p-5">
          <div className="flex items-center justify-between">
            <h3 className="text-xs tracking-cinematic text-neutral dark:text-neutral/80">Recovery targets</h3>
            <span className="text-xs text-neutral dark:text-neutral/80">{recoveryTargets.length} selected</span>
          </div>

          <p className="mt-2 text-xs text-neutral dark:text-neutral/80">
            Choose affected services to recover. Start with upstream services like Power Grid for
            cascade recovery.
          </p>

          {recoverableServices.length === 0 ? (
            <p className="mt-4 text-sm text-neutral dark:text-neutral/80">No affected services remain.</p>
          ) : (
            <ul className="mt-4 max-h-64 space-y-2 overflow-y-auto">
              {recoverableServices.map((service) => {
                const selected = recoveryTargets.includes(service.id)

                 return (
                  <li key={service.id}>
                    <button
                      type="button"
                      disabled={isRunning}
                      onClick={() => onToggleRecoveryTarget(service.id)}
                      aria-pressed={selected}
                      aria-label={`Toggle recovery action for ${service.name} which is currently ${service.state.toLowerCase()}`}
                      className={`flex w-full items-center justify-between rounded-md border px-3 py-2 text-left text-sm transition-colors disabled:opacity-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-success dark:focus-visible:ring-white focus-visible:ring-offset-2 ${
                        selected
                          ? 'border-success/30 bg-success/5 text-navy dark:border-success/50 dark:bg-success/15 dark:text-white'
                          : 'border-navy/10 dark:border-white/10 text-navy dark:text-white hover:bg-surface dark:hover:bg-navy/40'
                      }`}
                    >
                      <span>
                        {service.name}
                        <span className="ml-2 text-xs text-neutral dark:text-neutral/60">({service.state})</span>
                      </span>
                      <Timer
                        className={`h-4 w-4 ${selected ? 'text-success' : 'text-neutral/40'}`}
                        aria-hidden="true"
                      />
                    </button>
                  </li>
                )
              })}
            </ul>
          )}
        </div>
      )}
    </div>
  )
}
