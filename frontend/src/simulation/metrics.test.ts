import { describe, expect, it } from 'vitest'
import { calculateMetrics, countCriticalAffected, mergeRecoveryMetrics } from './metrics'
import type { SimulationResult } from './types'
import type { Service } from '@/types/graph'

describe('Simulation Metrics Calculation', () => {
  const mockServices: Service[] = [
    {
      id: 'svc-power',
      name: 'Power Grid',
      slug: 'power-grid',
      category: 'Energy',
      criticality: 5,
      state: 'HEALTHY',
    },
    {
      id: 'svc-hospital',
      name: 'Hospital',
      slug: 'hospital',
      category: 'Healthcare',
      criticality: 4,
      state: 'HEALTHY',
    },
    {
      id: 'svc-water',
      name: 'Water Plant',
      slug: 'water-plant',
      category: 'Water',
      criticality: 3,
      state: 'HEALTHY',
    },
  ]

  it('should count critical affected services based on threshold >= 4', () => {
    const affectedIds = new Set(['svc-power', 'svc-water'])
    const count = countCriticalAffected(mockServices, affectedIds)
    // svc-power is criticality 5 (>=4), svc-water is 3 (<4). So count should be 1.
    expect(count).toBe(1)
  })

  it('should calculate base metrics correctly', () => {
    const mockResult: SimulationResult = {
      events: [
        {
          simulationTime: 0,
          serviceId: 'svc-power',
          eventType: 'FAILURE',
          newState: 'FAILED',
        },
        {
          simulationTime: 2,
          serviceId: 'svc-hospital',
          eventType: 'DEGRADATION',
          newState: 'DEGRADED',
        },
      ],
      snapshots: [],
      finalStates: {},
      runtimeStates: {},
      metrics: {
        affectedServices: 2,
        cascadeDepth: 1,
        recoveryTime: 0,
      },
      completedAt: 5,
      firstDisruptionTime: 0,
    }

    const metrics = calculateMetrics(mockResult, mockServices)

    expect(metrics.affectedServices).toBe(2)
    expect(metrics.cascadeDepth).toBe(1)
    expect(metrics.recoveryTime).toBe(0)
    // 2 affected out of 3 = 66.7%
    expect(metrics.impactPercentage).toBe(66.7)
    // Both svc-power (5) and svc-hospital (4) are critical services
    expect(metrics.criticalServicesAffected).toBe(2)
    expect(metrics.totalServices).toBe(3)
  })

  it('should merge recovery metrics', () => {
    const baseMetrics = {
      affectedServices: 2,
      cascadeDepth: 1,
      recoveryTime: 0,
      impactPercentage: 66.7,
      criticalServicesAffected: 2,
      totalServices: 3,
    }

    const mockRecoveryResult = {
      recoveryTime: 25,
      completedAt: 30,
      snapshots: [],
      events: [],
      finalStates: {},
    }

    const merged = mergeRecoveryMetrics(baseMetrics, mockRecoveryResult)

    expect(merged.recoveryTime).toBe(25)
    expect(merged.impactPercentage).toBe(66.7)
  })
})
