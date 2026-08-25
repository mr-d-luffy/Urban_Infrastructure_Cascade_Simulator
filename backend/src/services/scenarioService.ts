import { store, type ScenarioRecord } from '../repositories/memoryStore.js'
import type { Disruption } from '../simulation/types.js'
import { AppError } from '../utils/AppError.js'
import { sanitizeScenarioName } from '../middleware/validate.js'
import { databaseScenario, databaseScenarios, removeDatabaseScenario, saveScenario } from '../db/repository.js'

export async function listScenarios() {
  return (await databaseScenarios()) ?? [...store.scenarios.values()]
}

export async function getScenarioById(id: string) {
  const fromDatabase = await databaseScenario(id)
  const scenario = fromDatabase === undefined ? store.scenarios.get(id) : fromDatabase
  if (!scenario) {
    throw new AppError(404, 'SCENARIO_NOT_FOUND', 'Scenario was not found.')
  }
  return scenario
}

export async function createScenario(input: {
  name: string
  description?: string
  seed?: number
  durationSeconds?: number
  tickSeconds?: number
  disruptions?: Disruption[]
}): Promise<ScenarioRecord> {
  const now = new Date().toISOString()
  const scenario: ScenarioRecord = {
    id: crypto.randomUUID(),
    name: sanitizeScenarioName(input.name),
    description: input.description?.trim() ?? null,
    seed: input.seed ?? 42003,
    durationSeconds: input.durationSeconds ?? 60,
    tickSeconds: input.tickSeconds ?? 1,
    disruptions: input.disruptions ?? [],
    createdAt: now,
    updatedAt: now,
  }
  if (!(await saveScenario(scenario))) store.scenarios.set(scenario.id, scenario)
  return scenario
}

export async function updateScenario(
  id: string,
  input: Partial<{
    name: string
    description: string
    seed: number
    durationSeconds: number
    tickSeconds: number
    disruptions: Disruption[]
  }>,
): Promise<ScenarioRecord> {
  const existing = await getScenarioById(id)
  const updated: ScenarioRecord = {
    ...existing,
    name: input.name ? sanitizeScenarioName(input.name) : existing.name,
    description: input.description?.trim() ?? existing.description,
    seed: input.seed ?? existing.seed,
    durationSeconds: input.durationSeconds ?? existing.durationSeconds,
    tickSeconds: input.tickSeconds ?? existing.tickSeconds,
    disruptions: input.disruptions ?? existing.disruptions,
    updatedAt: new Date().toISOString(),
  }
  if (!(await saveScenario(updated))) store.scenarios.set(id, updated)
  return updated
}

export async function deleteScenario(id: string) {
  const databaseDeleted = await removeDatabaseScenario(id)
  if (databaseDeleted === null && !store.scenarios.delete(id)) {
    throw new AppError(404, 'SCENARIO_NOT_FOUND', 'Scenario was not found.')
  }
  if (databaseDeleted === false) {
    throw new AppError(404, 'SCENARIO_NOT_FOUND', 'Scenario was not found.')
  }
}
