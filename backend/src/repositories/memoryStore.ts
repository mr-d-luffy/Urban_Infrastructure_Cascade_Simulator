import { DEMO_SCENARIO, SEED_DEPENDENCIES, SEED_SERVICES } from '../data/seedInfrastructure.js'
import type { Dependency, Service } from '../types/graph.js'
import type { SimulationRecord } from '../types/simulation.js'
import type { Disruption, ServiceRuntime } from '../simulation/types.js'

export interface ScenarioRecord {
  id: string
  name: string
  description: string | null
  seed: number
  durationSeconds: number
  tickSeconds: number
  disruptions: Disruption[]
  createdAt: string
  updatedAt: string
}

export interface StoredSimulation {
  record: SimulationRecord
  runtimeStates: Record<string, ServiceRuntime>
  initialRuntimeStates: Record<string, ServiceRuntime>
}

class MemoryStore {
  services: Service[] = [...SEED_SERVICES]
  dependencies: Dependency[] = [...SEED_DEPENDENCIES]
  scenarios = new Map<string, ScenarioRecord>()
  simulations = new Map<string, StoredSimulation>()

  constructor() {
    const now = new Date().toISOString()
    const demoId = crypto.randomUUID()
    this.scenarios.set(demoId, {
      id: demoId,
      ...DEMO_SCENARIO,
      description: DEMO_SCENARIO.description,
      createdAt: now,
      updatedAt: now,
    })
  }
}

export const store = new MemoryStore()
