import { describe, expect, it, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import { ScenarioManager } from './ScenarioManager'
import { api } from '@/services/api'

vi.mock('@/services/api', () => ({
  api: {
    getScenarios: vi.fn(() => Promise.resolve({ success: true, data: [] })),
    createScenario: vi.fn(),
    updateScenario: vi.fn(),
    deleteScenario: vi.fn(),
  },
}))

describe('ScenarioManager Component', () => {
  const defaultProps = {
    disruptions: [],
    disabled: false,
    onLoad: vi.fn(),
  }

  it('renders ScenarioManager panel header', async () => {
    render(<ScenarioManager {...defaultProps} />)
    expect(screen.getByText('Saved scenarios')).toBeDefined()
  })

  it('shows loading message when loading', async () => {
    render(<ScenarioManager {...defaultProps} />)
    expect(screen.getByText('Loading scenarios…')).toBeDefined()
  })

  it('renders scenario list when load finishes', async () => {
    const mockScenarios = [
      {
        id: '1',
        name: 'Power Failure Test',
        description: null,
        seed: 123,
        durationSeconds: 60,
        tickSeconds: 1,
        disruptions: [],
      },
    ]

    vi.mocked(api.getScenarios).mockResolvedValueOnce({
      success: true,
      data: mockScenarios,
      error: null,
    })

    render(<ScenarioManager {...defaultProps} />)
    
    // Wait for the scenario to be rendered
    const element = await screen.findByText('Power Failure Test')
    expect(element).toBeDefined()
  })
})
