import { describe, expect, it } from 'vitest'
import {
  applyDisruptions,
  evaluateDependencyPropagation,
} from './propagation'
import type { ServiceRuntime } from './types'
import type { SimulationEvent } from '../types/simulation'

describe('Simulation Propagation Logic', () => {
  it('should apply critical disruptions correctly', () => {
    const runtimeStates: Record<string, ServiceRuntime> = {
      'svc-power': {
        id: 'svc-power',
        state: 'HEALTHY',
        stress: 0,
        disrupted: false,
        firstAffectedTime: null,
        recoveryTicksRemaining: null,
      },
    }
    const disruptions = [{ serviceId: 'svc-power', startTime: 0, severity: 1.0 }]
    const events: SimulationEvent[] = []

    const changed = applyDisruptions(runtimeStates, disruptions, 0, events)

    expect(changed).toBe(true)
    expect(runtimeStates['svc-power'].state).toBe('FAILED')
    expect(runtimeStates['svc-power'].stress).toBe(1.0)
    expect(runtimeStates['svc-power'].disrupted).toBe(true)
    expect(events).toHaveLength(1)
    expect(events[0].eventType).toBe('FAILURE')
  })

  it('should apply partial degradation disruptions correctly', () => {
    const runtimeStates: Record<string, ServiceRuntime> = {
      'svc-power': {
        id: 'svc-power',
        state: 'HEALTHY',
        stress: 0,
        disrupted: false,
        firstAffectedTime: null,
        recoveryTicksRemaining: null,
      },
    }
    const disruptions = [{ serviceId: 'svc-power', startTime: 0, severity: 0.6 }]
    const events: SimulationEvent[] = []

    const changed = applyDisruptions(runtimeStates, disruptions, 0, events)

    expect(changed).toBe(true)
    expect(runtimeStates['svc-power'].state).toBe('DEGRADED')
    expect(runtimeStates['svc-power'].stress).toBe(0.6)
    expect(events[0].eventType).toBe('DEGRADATION')
  })

  it('should propagate failure to dependent services when stress exceeds threshold', () => {
    const runtimeStates: Record<string, ServiceRuntime> = {
      'svc-power': {
        id: 'svc-power',
        state: 'FAILED',
        stress: 1.0,
        disrupted: true,
        firstAffectedTime: 0,
        recoveryTicksRemaining: null,
      },
      'svc-water': {
        id: 'svc-water',
        state: 'HEALTHY',
        stress: 0,
        disrupted: false,
        firstAffectedTime: null,
        recoveryTicksRemaining: null,
      },
    }

    const upstreamMap = new Map([
      ['svc-water', [{ sourceServiceId: 'svc-power', dependencyStrength: 1.0 }]],
    ])
    const events: SimulationEvent[] = []

    const changed = evaluateDependencyPropagation(runtimeStates, upstreamMap, 1, events)

    expect(changed).toBe(true)
    expect(runtimeStates['svc-water'].state).toBe('FAILED')
    expect(runtimeStates['svc-water'].stress).toBe(1.0)
    expect(events[0].eventType).toBe('FAILURE')
  })

  it('should propagate partial degradation to dependent services', () => {
    const runtimeStates: Record<string, ServiceRuntime> = {
      'svc-power': {
        id: 'svc-power',
        state: 'DEGRADED',
        stress: 0.6,
        disrupted: true,
        firstAffectedTime: 0,
        recoveryTicksRemaining: null,
      },
      'svc-water': {
        id: 'svc-water',
        state: 'HEALTHY',
        stress: 0,
        disrupted: false,
        firstAffectedTime: null,
        recoveryTicksRemaining: null,
      },
    }

    // Upstream DEGRADED stress = strength * 0.5 = 1.0 * 0.5 = 0.5 (which meets DEGRADED threshold)
    const upstreamMap = new Map([
      ['svc-water', [{ sourceServiceId: 'svc-power', dependencyStrength: 1.0 }]],
    ])
    const events: SimulationEvent[] = []

    const changed = evaluateDependencyPropagation(runtimeStates, upstreamMap, 1, events)

    expect(changed).toBe(true)
    expect(runtimeStates['svc-water'].state).toBe('DEGRADED')
    expect(runtimeStates['svc-water'].stress).toBe(0.5)
  })
})
