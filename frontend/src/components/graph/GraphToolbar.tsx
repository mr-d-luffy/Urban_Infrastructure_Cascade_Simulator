import { Maximize2, ZoomIn, ZoomOut } from 'lucide-react'
import { useReactFlow } from '@xyflow/react'

export function GraphToolbar() {
  const { zoomIn, zoomOut, fitView } = useReactFlow()

  return (
    <div className="absolute right-3 top-3 z-10 flex gap-2">
      <button
        type="button"
        aria-label="Zoom in"
        onClick={() => zoomIn({ duration: 200 })}
        className="rounded-md border border-navy/10 dark:border-white/10 bg-white dark:bg-[#1D3045] p-2 text-navy dark:text-white shadow-sm transition-colors hover:bg-surface dark:hover:bg-navy/40"
      >
        <ZoomIn className="h-4 w-4" />
      </button>
      <button
        type="button"
        aria-label="Zoom out"
        onClick={() => zoomOut({ duration: 200 })}
        className="rounded-md border border-navy/10 dark:border-white/10 bg-white dark:bg-[#1D3045] p-2 text-navy dark:text-white shadow-sm transition-colors hover:bg-surface dark:hover:bg-navy/40"
      >
        <ZoomOut className="h-4 w-4" />
      </button>
      <button
        type="button"
        aria-label="Fit graph to screen"
        onClick={() => fitView({ padding: 0.2, duration: 300 })}
        className="rounded-md border border-navy/10 dark:border-white/10 bg-white dark:bg-[#1D3045] p-2 text-navy dark:text-white shadow-sm transition-colors hover:bg-surface dark:hover:bg-navy/40"
      >
        <Maximize2 className="h-4 w-4" />
      </button>
    </div>
  )
}
