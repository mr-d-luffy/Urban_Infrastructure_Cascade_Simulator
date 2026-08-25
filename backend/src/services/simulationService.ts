import { store, type StoredSimulation } from '../repositories/memoryStore.js'
import { DEFAULT_SIMULATION_CONFIG, runSimulation } from '../simulation/engine.js'
import {
  buildRecoveryDurations,
  calculateMetrics,
  mergeRecoveryMetrics,
} from '../simulation/metrics.js'
import { runRecoverySimulation } from '../simulation/recovery.js'
import type { Disruption } from '../simulation/types.js'
import { cloneRuntimeStates, createRuntimeStates } from '../simulation/types.js'
import type { SimulationRecord } from '../types/simulation.js'
import { getScenarioById } from './scenarioService.js'
import { AppError } from '../utils/AppError.js'
import { listDependencies, listServices } from './graphService.js'
import { databaseSimulation, saveSimulation } from '../db/repository.js'

async function toEngineDependencies() {
  return listDependencies()
}

async function buildRecoveryDurationMap() {
  return buildRecoveryDurations(
    (await listServices()).map((service) => ({
      id: service.id,
      criticality: service.criticality,
    })),
  )
}

export async function getSimulationById(id: string): Promise<StoredSimulation> {
  const simulation = store.simulations.get(id)
  if (simulation) return simulation

  const persisted = await databaseSimulation(id)
  if (persisted) {
    const runtimeStates = createRuntimeStates(Object.keys(persisted.finalStates))
    for (const [serviceId, state] of Object.entries(persisted.finalStates)) {
      runtimeStates[serviceId]!.state = state
    }
    return {
      record: persisted,
      runtimeStates,
      initialRuntimeStates: createRuntimeStates(Object.keys(persisted.finalStates)),
    }
  }
  throw new AppError(404, 'SIMULATION_NOT_FOUND', 'Simulation was not found.')
}

export async function runSimulationFromRequest(input: {
  scenarioId?: string
  disruptions?: Disruption[]
}) {
  let disruptions = input.disruptions ?? []
  let config = { ...DEFAULT_SIMULATION_CONFIG }
  let scenarioId: string | null = null

  if (input.scenarioId) {
    const scenario = await getScenarioById(input.scenarioId)
    scenarioId = scenario.id
    disruptions = scenario.disruptions
    config = {
      seed: scenario.seed,
      durationSeconds: scenario.durationSeconds,
      tickSeconds: scenario.tickSeconds,
    }
  }

  if (disruptions.length === 0) {
    throw new AppError(400, 'VALIDATION_ERROR', 'At least one disruption is required.')
  }

  const services = await listServices()
  for (const disruption of disruptions) {
    const exists = services.some((service) => service.id === disruption.serviceId)
    if (!exists) {
      throw new AppError(400, 'SERVICE_NOT_FOUND', `Service ${disruption.serviceId} not found.`)
    }
  }

  const serviceIds = services.map((service) => service.id)
  const result = runSimulation({
    serviceIds,
    dependencies: await toEngineDependencies(),
    disruptions,
    config,
    recoveryDurations: await buildRecoveryDurationMap(),
  })

  const metrics = calculateMetrics(result, services)
  const startedAt = new Date().toISOString()

  const record: SimulationRecord = {
    id: crypto.randomUUID(),
    scenarioId,
    status: 'COMPLETED',
    disruptions,
    events: result.events,
    metrics,
    finalStates: result.finalStates,
    completedAt: result.completedAt,
    firstDisruptionTime: result.firstDisruptionTime,
    startedAt,
    completedAtTs: new Date().toISOString(),
  }

  store.simulations.set(record.id, {
    record,
    runtimeStates: cloneRuntimeStates(result.runtimeStates),
    initialRuntimeStates: createRuntimeStates(serviceIds),
  })

  await saveSimulation(record)

  return record
}

export async function applyRecovery(simulationId: string, serviceIds: string[]) {
  const stored = await getSimulationById(simulationId)

  if (stored.record.status !== 'COMPLETED') {
    throw new AppError(400, 'SIMULATION_NOT_READY', 'Simulation must be completed first.')
  }

  for (const serviceId of serviceIds) {
    const exists = (await listServices()).some((service) => service.id === serviceId)
    if (!exists) {
      throw new AppError(400, 'SERVICE_NOT_FOUND', `Service ${serviceId} not found.`)
    }
  }

  const recoveryDurations = await buildRecoveryDurationMap()
  const startTime = stored.record.completedAt
  const recoveryActions = serviceIds.map((serviceId) => ({
    serviceId,
    startTime: startTime + DEFAULT_SIMULATION_CONFIG.tickSeconds,
  }))

  const result = runRecoverySimulation({
    runtimeStates: stored.runtimeStates,
    dependencies: await toEngineDependencies(),
    recoveryActions,
    recoveryDurations,
    config: { ...DEFAULT_SIMULATION_CONFIG, durationSeconds: 90 },
    startTime,
    firstDisruptionTime: stored.record.firstDisruptionTime,
  })

  const updatedMetrics = mergeRecoveryMetrics(stored.record.metrics, result)
  const updatedRecord: SimulationRecord = {
    ...stored.record,
    events: [...stored.record.events, ...result.events],
    metrics: updatedMetrics,
    finalStates: result.finalStates,
    completedAt: result.completedAt,
    completedAtTs: new Date().toISOString(),
  }

  store.simulations.set(simulationId, {
    ...stored,
    record: updatedRecord,
    runtimeStates: cloneRuntimeStates(
      Object.fromEntries(
        Object.entries(result.finalStates).map(([id, state]) => [
          id,
          {
            ...(stored.runtimeStates[id] ?? {
              id,
              stress: 0,
              disrupted: false,
              firstAffectedTime: null,
              recoveryTicksRemaining: null,
            }),
            state,
            recoveryTicksRemaining: null,
          },
        ]),
      ),
    ),
  })

  await saveSimulation(updatedRecord)

  return updatedRecord
}

export async function resetSimulation(simulationId: string) {
  const stored = await getSimulationById(simulationId)
  const serviceIds = (await listServices()).map((service) => service.id)

  const resetRecord: SimulationRecord = {
    ...stored.record,
    status: 'CANCELLED',
    events: [],
    metrics: {
      affectedServices: 0,
      cascadeDepth: 0,
      recoveryTime: 0,
      impactPercentage: 0,
      criticalServicesAffected: 0,
      totalServices: serviceIds.length,
    },
    finalStates: Object.fromEntries(serviceIds.map((id) => [id, 'HEALTHY'])),
    completedAt: 0,
    firstDisruptionTime: 0,
    completedAtTs: new Date().toISOString(),
  }

  store.simulations.set(simulationId, {
    record: resetRecord,
    runtimeStates: createRuntimeStates(serviceIds),
    initialRuntimeStates: createRuntimeStates(serviceIds),
  })

  await saveSimulation(resetRecord)

  return resetRecord
}

export async function getSimulationEvents(simulationId: string) {
  return (await getSimulationById(simulationId)).record.events
}
