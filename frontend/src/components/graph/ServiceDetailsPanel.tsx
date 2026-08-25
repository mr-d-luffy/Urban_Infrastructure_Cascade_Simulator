import type { Service } from '@/types/graph'
import { STATE_STYLES } from '@/utils/graphHelpers'
import { X } from 'lucide-react'

interface ServiceDetailsPanelProps {
  service: Service
  upstream: Service[]
  downstream: Service[]
  onClose: () => void
  onSelectService: (id: string) => void
}

export function ServiceDetailsPanel({
  service,
  upstream,
  downstream,
  onClose,
  onSelectService,
}: ServiceDetailsPanelProps) {
  const styles = STATE_STYLES[service.state]

  return (
    <div className="rounded-lg border border-navy/10 dark:border-white/10 bg-white dark:bg-[#132230] p-5">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="text-[10px] tracking-cinematic text-neutral dark:text-neutral/80">SERVICE DETAILS</p>
          <h3 className="mt-1 text-lg font-medium text-navy dark:text-white">{service.name}</h3>
        </div>
        <button
          type="button"
          aria-label="Close service details"
          onClick={onClose}
          className="rounded p-1 text-neutral transition-colors hover:text-navy dark:text-slate-400 dark:hover:text-white"
        >
          <X className="h-4 w-4" />
        </button>
      </div>

      <div className="mt-4 flex items-center gap-2">
        <span className={`inline-block h-2.5 w-2.5 rounded-full ${styles.dot}`} />
        <span className={`text-sm font-medium ${styles.label}`}>{service.state}</span>
      </div>

      <dl className="mt-5 space-y-3 text-sm">
        <div>
          <dt className="text-[10px] tracking-cinematic text-neutral dark:text-neutral/80">CATEGORY</dt>
          <dd className="mt-0.5 text-navy dark:text-white">{service.category}</dd>
        </div>
        <div>
          <dt className="text-[10px] tracking-cinematic text-neutral dark:text-neutral/80">CRITICALITY</dt>
          <dd className="mt-0.5 text-navy dark:text-white">{service.criticality} / 5</dd>
        </div>
        {service.description && (
          <div>
            <dt className="text-[10px] tracking-cinematic text-neutral dark:text-neutral/80">DESCRIPTION</dt>
            <dd className="mt-0.5 text-neutral dark:text-neutral/80">{service.description}</dd>
          </div>
        )}
      </dl>

      <DependencyList
        title="Depends on"
        emptyLabel="No upstream dependencies"
        services={upstream}
        onSelectService={onSelectService}
      />

      <DependencyList
        title="Dependents"
        emptyLabel="No downstream dependents"
        services={downstream}
        onSelectService={onSelectService}
      />
    </div>
  )
}

function DependencyList({
  title,
  emptyLabel,
  services,
  onSelectService,
}: {
  title: string
  emptyLabel: string
  services: Service[]
  onSelectService: (id: string) => void
}) {
  return (
    <div className="mt-5">
      <p className="text-[10px] tracking-cinematic text-neutral dark:text-neutral/80">{title.toUpperCase()}</p>
      {services.length === 0 ? (
        <p className="mt-2 text-sm text-neutral dark:text-neutral/80">{emptyLabel}</p>
      ) : (
        <ul className="mt-2 space-y-1">
          {services.map((item) => (
            <li key={item.id}>
              <button
                type="button"
                onClick={() => onSelectService(item.id)}
                className="w-full rounded px-2 py-1.5 text-left text-sm text-navy dark:text-white transition-colors hover:bg-surface dark:hover:bg-navy/40"
              >
                {item.name}
                <span className="ml-2 text-xs text-neutral dark:text-neutral/60">({item.state})</span>
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
