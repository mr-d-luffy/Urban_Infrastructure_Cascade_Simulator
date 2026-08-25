import { describe, expect, it, vi } from 'vitest'
import { fireEvent, render, screen } from '@testing-library/react'
import { SimulationControls } from './SimulationControls'
import type { Service } from '@/types/graph'

describe('SimulationControls Component', () => {
  const mockServices: Service[] = [
    {
      id: 'svc-power',
      name: 'Power Grid',
      slug: 'power-grid',
      category: 'Energy',
      criticality: 5,
      state: 'HEALTHY',
    },
  ]

  const defaultProps = {
    services: mockServices,
    disruptions: [],
    recoveryTargets: [],
    recoverableServices: [],
    selectedId: null,
    status: 'IDLE' as const,
    phase: 'idle' as const,
    simulationTime: 0,
    metrics: null,
    error: null,
    onToggleDisruption: vi.fn(),
    onToggleRecoveryTarget: vi.fn(),
    onLoadDemo: vi.fn(),
    onRun: vi.fn(),
    onRecover: vi.fn(),
    onReset: vi.fn(),
  }

  it('renders simulation control buttons', () => {
    render(<SimulationControls {...defaultProps} />)
    expect(screen.getByText('Load power failure demo')).toBeDefined()
    expect(screen.getByText('Run simulation')).toBeDefined()
    expect(screen.getByText('Start recovery')).toBeDefined()
    expect(screen.getByText('Reset')).toBeDefined()
  })

  it('triggers onLoadDemo when clicking demo button', () => {
    render(<SimulationControls {...defaultProps} />)
    const button = screen.getByText('Load power failure demo')
    fireEvent.click(button)
    expect(defaultProps.onLoadDemo).toHaveBeenCalled()
  })

  it('enables the Run button when there are disruptions selected', () => {
    const props = {
      ...defaultProps,
      disruptions: [{ serviceId: 'svc-power', startTime: 0, severity: 1.0 }],
    }
    render(<SimulationControls {...props} />)
    const runBtn = screen.getByText('Run simulation') as HTMLButtonElement
    expect(runBtn.disabled).toBe(false)
    fireEvent.click(runBtn)
    expect(defaultProps.onRun).toHaveBeenCalled()
  })

  it('disables the Run button when no disruptions are selected', () => {
    render(<SimulationControls {...defaultProps} />)
    const runBtn = screen.getByText('Run simulation') as HTMLButtonElement
    expect(runBtn.disabled).toBe(true)
  })
})
