interface MetricCardProps {
  label: string
  value: string
  hint?: string
}

export function MetricCard({ label, value, hint }: MetricCardProps) {
  return (
    <div className="rounded-lg border border-navy/10 dark:border-white/10 bg-white dark:bg-[#132230] px-5 py-4">
      <p className="text-[10px] tracking-cinematic text-neutral dark:text-neutral/80">{label}</p>
      <p className="mt-2 text-3xl font-light tabular-nums text-navy dark:text-white">{value}</p>
      {hint && <p className="mt-1 text-xs text-neutral dark:text-neutral/60">{hint}</p>}
    </div>
  )
}
