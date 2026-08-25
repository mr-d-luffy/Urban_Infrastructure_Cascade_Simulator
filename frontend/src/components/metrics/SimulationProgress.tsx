import { formatTimelineTime } from '@/utils/timelineHelpers'

interface SimulationProgressProps {
  simulationTime: number
  totalDuration: number
  phase: string
  status: string
}

export function SimulationProgress({
  simulationTime,
  totalDuration,
  phase,
  status,
}: SimulationProgressProps) {
  const progress =
    totalDuration > 0 ? Math.min((simulationTime / totalDuration) * 100, 100) : 0
  const isActive = status === 'RUNNING'

  return (
    <div className="rounded-lg border border-navy/10 dark:border-white/10 bg-white dark:bg-[#132230] p-5">
      <div className="flex items-center justify-between gap-4">
        <div>
          <p className="text-[10px] tracking-cinematic text-neutral dark:text-neutral/80">Simulation Progress</p>
          <p className="mt-1 text-sm text-navy dark:text-white">
            T+{formatTimelineTime(simulationTime)}
            {totalDuration > 0 && (
              <span className="text-neutral dark:text-neutral/60"> / T+{formatTimelineTime(totalDuration)}</span>
            )}
          </p>
        </div>
        <p className="text-xs tracking-wide text-neutral dark:text-neutral/80 capitalize">
          {phase}
          {isActive && ' · running'}
        </p>
      </div>

      <div className="mt-4 h-1.5 overflow-hidden rounded-full bg-surface dark:bg-navy">
        <div
          className={`h-full rounded-full transition-all duration-300 ${
            isActive ? 'bg-warning' : phase === 'complete' ? 'bg-success' : 'bg-navy dark:bg-white'
          }`}
          style={{ width: `${progress}%` }}
          role="progressbar"
          aria-valuenow={Math.round(progress)}
          aria-valuemin={0}
          aria-valuemax={100}
          aria-label="Simulation progress"
        />
      </div>
    </div>
  )
}
