import { MetricCard } from '@/components/metrics/MetricCard'
import { formatMetricValue, formatRecoveryTime } from '@/simulation/metrics'
import type { SimulationMetrics } from '@/types/simulation'

interface MetricCardsProps {
  metrics: SimulationMetrics | null
  phase: string
}

export function MetricCards({ metrics, phase }: MetricCardsProps) {
  if (!metrics) {
    return (
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {['Affected Services', 'Cascade Depth', 'Recovery Time', 'System Impact'].map((label) => (
          <div
            key={label}
            className="rounded-lg border border-dashed border-navy/15 dark:border-white/10 bg-white/60 dark:bg-[#132230]/40 px-5 py-4"
          >
            <p className="text-[10px] tracking-cinematic text-neutral dark:text-neutral/80">{label}</p>
            <p className="mt-2 text-3xl font-light text-neutral/40 dark:text-slate-500">—</p>
          </div>
        ))}
      </div>
    )
  }

  const recoveryValue =
    metrics.recoveryTime > 0
      ? formatRecoveryTime(metrics.recoveryTime)
      : phase === 'complete'
        ? '—'
        : '—'

  return (
    <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      <MetricCard
        label="Affected Services"
        value={formatMetricValue(metrics.affectedServices)}
        hint={
          metrics.criticalServicesAffected > 0
            ? `${metrics.criticalServicesAffected} critical`
            : undefined
        }
      />
      <MetricCard
        label="Cascade Depth"
        value={formatMetricValue(metrics.cascadeDepth)}
      />
      <MetricCard label="Recovery Time" value={recoveryValue} />
      <MetricCard
        label="System Impact"
        value={`${metrics.impactPercentage}%`}
        hint={`${metrics.totalServices} total services`}
      />
    </div>
  )
}
