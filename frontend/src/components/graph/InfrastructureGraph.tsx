import { ServiceNode, type ServiceNodeData } from '@/components/graph/ServiceNode'
import { GraphToolbar } from '@/components/graph/GraphToolbar'
import type { Dependency, Service } from '@/types/graph'
import {
  Background,
  Controls,
  ReactFlow,
  ReactFlowProvider,
  type Edge,
  type Node,
  type NodeTypes,
} from '@xyflow/react'
import '@xyflow/react/dist/style.css'
import { useCallback, useEffect, useMemo } from 'react'

const nodeTypes: NodeTypes = {
  serviceNode: ServiceNode,
}

interface InfrastructureGraphProps {
  services: Service[]
  dependencies: Dependency[]
  selectedId: string | null
  activeEdgeIds?: string[]
  onSelectService: (id: string | null) => void
}

function toNodes(services: Service[], selectedId: string | null): Node[] {
  return services.map((service) => ({
    id: service.id,
    type: 'serviceNode',
    position: service.position ?? { x: 0, y: 0 },
    data: {
      name: service.name,
      category: service.category,
      state: service.state,
      criticality: service.criticality,
      selected: service.id === selectedId,
    } satisfies ServiceNodeData,
  }))
}

function toEdges(dependencies: Dependency[], activeEdgeIds: string[]): Edge[] {
  return dependencies.map((dep) => {
    const isActive = activeEdgeIds.includes(dep.id)
    return {
      id: dep.id,
      source: dep.sourceServiceId,
      target: dep.targetServiceId,
      type: 'smoothstep',
      animated: isActive,
      style: {
        stroke: isActive ? '#C94B4B' : '#7B8794',
        strokeWidth: isActive ? 2 : 1.5,
      },
      markerEnd: {
        type: 'arrowclosed' as const,
        color: isActive ? '#C94B4B' : '#7B8794',
        width: 16,
        height: 16,
      },
    }
  })
}

function GraphCanvas({
  services,
  dependencies,
  selectedId,
  activeEdgeIds = [],
  onSelectService,
}: InfrastructureGraphProps) {
  const nodes = useMemo(() => toNodes(services, selectedId), [services, selectedId])
  const edges = useMemo(
    () => toEdges(dependencies, activeEdgeIds),
    [dependencies, activeEdgeIds],
  )

  const onNodeClick = useCallback(
    (_event: React.MouseEvent, node: Node) => {
      onSelectService(node.id)
    },
    [onSelectService],
  )

  const onPaneClick = useCallback(() => {
    onSelectService(null)
  }, [onSelectService])

  return (
    <div className="relative h-full min-h-[420px] w-full">
      <GraphToolbar />
      <ReactFlow
        nodes={nodes}
        edges={edges}
        nodeTypes={nodeTypes}
        onNodeClick={onNodeClick}
        onPaneClick={onPaneClick}
        fitView
        fitViewOptions={{ padding: 0.2 }}
        minZoom={0.4}
        maxZoom={1.8}
        proOptions={{ hideAttribution: true }}
        className="rounded-lg bg-surface/50 dark:bg-[#132230]/30"
      >
        <Background color="var(--flow-bg-dots)" gap={20} size={1} />
        <Controls
          showInteractive={false}
          className="!border-navy/10 dark:!border-white/10 !shadow-sm [&>button]:!border-navy/10 dark:[&>button]:!border-white/10 [&>button]:!bg-white dark:[&>button]:!bg-[#1D3045] [&>button]:!text-navy dark:[&>button]:!text-white"
        />
      </ReactFlow>
    </div>
  )
}

export function InfrastructureGraph(props: InfrastructureGraphProps) {
  useEffect(() => {
    const style = document.createElement('style')
    style.textContent = `
      .react-flow__node.selected { box-shadow: none; }
      .react-flow__controls-button svg { fill: currentColor; }
    `
    document.head.appendChild(style)
    return () => {
      document.head.removeChild(style)
    }
  }, [])

  return (
    <ReactFlowProvider>
      <GraphCanvas {...props} />
    </ReactFlowProvider>
  )
}
