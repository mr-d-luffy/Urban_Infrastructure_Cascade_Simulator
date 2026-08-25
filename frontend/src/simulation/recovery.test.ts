import { describe, expect, it } from 'vitest'
import {
  applyRecoveryStarts,
  promoteRecoveredServices,
  processRecoveryProgress,
} from './recovery'
import type { ServiceRuntime } from './types'
import type { SimulationEvent } from '../types/simulation'
import type { Dependency } from '@/types/graph'

describe('Simulation Recovery Logic', () => {
  it('should start recovery for failed services', () => {
    const runtimeStates: Record<string, ServiceRuntime> = {
      'svc-power': {
        id: 'svc-power',
        state: 'FAILED',
        stress: 1.0,
        disrupted: true,
        firstAffectedTime: 0,
        recoveryTicksRemaining: null,
      },
    }
    const actions = [{ serviceId: 'svc-power', startTime: 1 }]
    const recoveryDurations = { 'svc-power': 4 }
    const events: SimulationEvent[] = []

    const changed = applyRecoveryStarts(
      runtimeStates,
      actions,
      1,
      recoveryDurations,
      events,
    )

    expect(changed).toBe(true)
    expect(runtimeStates['svc-power'].state).toBe('RECOVERING')
    expect(runtimeStates['svc-power'].recoveryTicksRemaining).toBe(4)
    expect(events[0].eventType).toBe('RECOVERY_STARTED')
  })

  it('should progress recovery time and complete it', () => {
    const runtimeStates: Record<string, ServiceRuntime> = {
      'svc-power': {
        id: 'svc-power',
        state: 'RECOVERING',
        stress: 0.75,
        disrupted: true,
        firstAffectedTime: 0,
        recoveryTicksRemaining: 1,
      },
    }
    const events: SimulationEvent[] = []

    const changed = processRecoveryProgress(runtimeStates, 2, events)

    expect(changed).toBe(true)
    expect(runtimeStates['svc-power'].state).toBe('RECOVERED')
    expect(runtimeStates['svc-power'].recoveryTicksRemaining).toBeNull()
    expect(runtimeStates['svc-power'].disrupted).toBe(false)
    expect(events[0].eventType).toBe('RECOVERY_COMPLETED')
  })

  it('should promote RECOVERED state to HEALTHY when upstream dependencies are clean', () => {
    const runtimeStates: Record<string, ServiceRuntime> = {
      'svc-power': {
        id: 'svc-power',
        state: 'HEALTHY',
        stress: 0,
        disrupted: false,
        firstAffectedTime: 0,
        recoveryTicksRemaining: null,
      },
      'svc-water': {
        id: 'svc-water',
        state: 'RECOVERED',
        stress: 0,
        disrupted: false,
        firstAffectedTime: 1,
        recoveryTicksRemaining: null,
      },
    }
    const upstreamMap = new Map<string, Dependency[]>([
      [
        'svc-water',
        [
          {
            id: 'dep-1',
            sourceServiceId: 'svc-power',
            targetServiceId: 'svc-water',
            dependencyStrength: 1.0,
          },
        ],
      ],
    ])
    const events: SimulationEvent[] = []

    const changed = promoteRecoveredServices(runtimeStates, upstreamMap, 3, events)

    expect(changed).toBe(true)
    expect(runtimeStates['svc-water'].state).toBe('HEALTHY')
  })

  it('should return true when recovery is in progress to prevent premature simulation termination', () => {
    const runtimeStates: Record<string, ServiceRuntime> = {
      'svc-power': {
        id: 'svc-power',
        state: 'RECOVERING',
        stress: 0.75,
        disrupted: true,
        firstAffectedTime: 0,
        recoveryTicksRemaining: 3,
      },
    }
    const events: SimulationEvent[] = []

    const changed = processRecoveryProgress(runtimeStates, 2, events)

    expect(changed).toBe(true)
    expect(runtimeStates['svc-power'].recoveryTicksRemaining).toBe(2)
    expect(runtimeStates['svc-power'].state).toBe('RECOVERING')
  })
})
