import { describe, expect, it } from 'vitest'
import { render, screen } from '@testing-library/react'
import { SimulationTimeline } from './SimulationTimeline'
import type { SimulationEvent } from '@/types/simulation'
import type { Service } from '@/types/graph'

describe('SimulationTimeline Component', () => {
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

  const mockEvents: SimulationEvent[] = [
    {
      simulationTime: 0,
      serviceId: 'svc-power',
      eventType: 'FAILURE',
      newState: 'FAILED',
      reason: 'Initial disruption',
    },
  ]

  it('renders timeline with mapped service names and friendly event types', () => {
    render(
      <SimulationTimeline
        events={mockEvents}
        simulationTime={0}
        services={mockServices}
      />,
    )

    // Verify timeline header is rendered
    expect(screen.getByText('Timeline')).toBeDefined()

    // Verify friendly service name is displayed
    expect(screen.getByText(/Power Grid/)).toBeDefined()

    // Verify event details showing mapped friendly event types
    expect(screen.getByText(/Critical Failure/)).toBeDefined()
  })

  it('renders fallback ID when service name is not available', () => {
    render(
      <SimulationTimeline
        events={mockEvents}
        simulationTime={0}
        services={[]} // Empty services list
      />,
    )

    // Verify it falls back to displaying the raw serviceId
    expect(screen.getByText(/svc-power/)).toBeDefined()
  })
})
