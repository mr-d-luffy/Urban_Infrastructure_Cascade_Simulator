import type { ServiceState } from '@/types/graph'
import { STATE_STYLES } from '@/utils/graphHelpers'
import { Handle, Position, type NodeProps } from '@xyflow/react'
import {
  Building2,
  Bus,
  Droplets,
  Home,
  Radio,
  ShieldAlert,
  Trash2,
  Zap,
} from 'lucide-react'
import { memo } from 'react'

export interface ServiceNodeData {
  name: string
  category: string
  state: ServiceState
  criticality: number
  selected: boolean
}

const CATEGORY_ICONS: Record<string, typeof Zap> = {
  Energy: Zap,
  Water: Droplets,
  Healthcare: Building2,
  Transport: Bus,
  Communication: Radio,
  Emergency: ShieldAlert,
  Residential: Home,
  Waste: Trash2,
}

function ServiceNodeComponent({ data }: NodeProps) {
  const nodeData = data as unknown as ServiceNodeData
  const Icon = CATEGORY_ICONS[nodeData.category] ?? Zap
  const styles = STATE_STYLES[nodeData.state]

  return (
    <div
      className={`min-w-[180px] rounded-lg border bg-white dark:bg-[#132230] dark:border-white/10 px-4 py-3 shadow-sm transition-shadow ${
        styles.border
      } ${nodeData.selected ? 'ring-2 ring-navy/30 dark:ring-white/30 shadow-md' : ''}`}
    >
      <Handle type="target" position={Position.Top} className="!bg-neutral !w-2 !h-2 !border-0" />

      <div className="flex items-start gap-2">
        <Icon className="mt-0.5 h-4 w-4 shrink-0 text-navy dark:text-white" aria-hidden="true" />
        <div className="min-w-0">
          <p className="truncate text-sm font-medium text-navy dark:text-white">{nodeData.name}</p>
          <p className="text-[10px] tracking-wide text-neutral dark:text-neutral/80">{nodeData.category}</p>
        </div>
      </div>

      <div className="mt-3 flex items-center gap-2">
        <span
          className={`inline-block h-2 w-2 rounded-full ${styles.dot}`}
          aria-hidden="true"
        />
        <span className={`text-xs font-medium ${styles.label}`}>{nodeData.state}</span>
      </div>

      <Handle
        type="source"
        position={Position.Bottom}
        className="!bg-neutral !w-2 !h-2 !border-0"
      />
    </div>
  )
}

export const ServiceNode = memo(ServiceNodeComponent)
