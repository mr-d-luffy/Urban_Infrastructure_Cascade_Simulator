import type { Pool } from 'pg'
import { checkDatabaseConnection, getPool } from './pool.js'
import type { Dependency, Service, ServiceState } from '../types/graph.js'
import type { SimulationRecord } from '../types/simulation.js'
import type { Disruption } from '../simulation/types.js'

export interface DatabaseScenario {
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

async function database(): Promise<Pool | null> {
  return (await checkDatabaseConnection()) ? getPool() : null
}

const number = (value: unknown) => Number(value)

export async function databaseServices(): Promise<Service[] | null> {
  const pool = await database()
  if (!pool) return null
  const result = await pool.query(`SELECT id, name, slug, category, description, criticality, default_state, recovery_duration, created_at, updated_at FROM services ORDER BY name`)
  return result.rows.map((row) => ({ id: row.id, name: row.name, slug: row.slug, category: row.category, description: row.description ?? undefined, criticality: number(row.criticality), defaultState: row.default_state as ServiceState, recoveryDuration: number(row.recovery_duration), createdAt: row.created_at.toISOString(), updatedAt: row.updated_at.toISOString() }))
}

export async function databaseDependencies(): Promise<Dependency[] | null> {
  const pool = await database()
  if (!pool) return null
  const result = await pool.query(`SELECT id, source_service_id, target_service_id, dependency_strength, dependency_type, failure_threshold, created_at FROM dependencies ORDER BY created_at`)
  return result.rows.map((row) => ({ id: row.id, sourceServiceId: row.source_service_id, targetServiceId: row.target_service_id, dependencyStrength: number(row.dependency_strength), dependencyType: row.dependency_type, failureThreshold: number(row.failure_threshold), createdAt: row.created_at.toISOString() }))
}

async function readScenario(pool: Pool, id: string): Promise<DatabaseScenario | null> {
  const scenario = await pool.query('SELECT * FROM scenarios WHERE id = $1', [id])
  if (!scenario.rowCount) return null
  const disruptions = await pool.query('SELECT service_id, start_time, severity, duration FROM scenario_disruptions WHERE scenario_id = $1 ORDER BY start_time', [id])
  const row = scenario.rows[0]
  return { id: row.id, name: row.name, description: row.description, seed: number(row.seed), durationSeconds: number(row.duration_seconds), tickSeconds: number(row.tick_seconds), disruptions: disruptions.rows.map((item) => ({ serviceId: item.service_id, startTime: number(item.start_time), severity: number(item.severity), ...(item.duration === null ? {} : { duration: number(item.duration) }) })), createdAt: row.created_at.toISOString(), updatedAt: row.updated_at.toISOString() }
}

export async function databaseScenarios(): Promise<DatabaseScenario[] | null> {
  const pool = await database()
  if (!pool) return null
  const rows = await pool.query('SELECT id FROM scenarios ORDER BY created_at')
  return (await Promise.all(rows.rows.map((row) => readScenario(pool, row.id)))).filter((item): item is DatabaseScenario => item !== null)
}

export async function databaseScenario(id: string): Promise<DatabaseScenario | null | undefined> {
  const pool = await database()
  return pool ? readScenario(pool, id) : undefined
}

export async function saveScenario(scenario: DatabaseScenario): Promise<boolean> {
  const pool = await database()
  if (!pool) return false
  await pool.query('BEGIN')
  try {
    await pool.query(`INSERT INTO scenarios (id, name, description, seed, duration_seconds, tick_seconds) VALUES ($1,$2,$3,$4,$5,$6) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, seed = EXCLUDED.seed, duration_seconds = EXCLUDED.duration_seconds, tick_seconds = EXCLUDED.tick_seconds, updated_at = CURRENT_TIMESTAMP`, [scenario.id, scenario.name, scenario.description, scenario.seed, scenario.durationSeconds, scenario.tickSeconds])
    await pool.query('DELETE FROM scenario_disruptions WHERE scenario_id = $1', [scenario.id])
    for (const disruption of scenario.disruptions) await pool.query('INSERT INTO scenario_disruptions (scenario_id, service_id, start_time, severity, duration) VALUES ($1,$2,$3,$4,$5)', [scenario.id, disruption.serviceId, disruption.startTime, disruption.severity, disruption.duration ?? null])
    await pool.query('COMMIT')
    return true
  } catch (error) { await pool.query('ROLLBACK'); throw error }
}

export async function removeDatabaseScenario(id: string): Promise<boolean | null> {
  const pool = await database()
  if (!pool) return null
  return Boolean((await pool.query('DELETE FROM scenarios WHERE id = $1', [id])).rowCount)
}

export async function saveSimulation(record: SimulationRecord): Promise<boolean> {
  const pool = await database()
  if (!pool) return false
  await pool.query('BEGIN')
  try {
    await pool.query(`INSERT INTO simulations (id, scenario_id, status, disruptions_json, started_at, completed_at, simulation_duration, first_disruption_time, final_state) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) ON CONFLICT (id) DO UPDATE SET status=EXCLUDED.status, disruptions_json=EXCLUDED.disruptions_json, completed_at=EXCLUDED.completed_at, simulation_duration=EXCLUDED.simulation_duration, first_disruption_time=EXCLUDED.first_disruption_time, final_state=EXCLUDED.final_state`, [record.id, record.scenarioId, record.status, JSON.stringify(record.disruptions), record.startedAt, record.completedAtTs, record.completedAt, record.firstDisruptionTime, JSON.stringify(record.finalStates)])
    await pool.query('DELETE FROM simulation_events WHERE simulation_id = $1', [record.id])
    for (const event of record.events) await pool.query('INSERT INTO simulation_events (simulation_id, simulation_time, service_id, event_type, previous_state, new_state, reason) VALUES ($1,$2,$3,$4,$5,$6,$7)', [record.id, event.simulationTime, event.serviceId, event.eventType, event.previousState ?? null, event.newState ?? null, event.reason ?? null])
    const m = record.metrics
    await pool.query(`INSERT INTO simulation_metrics (simulation_id, affected_services, cascade_depth, recovery_time, critical_services_affected, impact_percentage) VALUES ($1,$2,$3,$4,$5,$6) ON CONFLICT (simulation_id) DO UPDATE SET affected_services=EXCLUDED.affected_services, cascade_depth=EXCLUDED.cascade_depth, recovery_time=EXCLUDED.recovery_time, critical_services_affected=EXCLUDED.critical_services_affected, impact_percentage=EXCLUDED.impact_percentage`, [record.id, m.affectedServices, m.cascadeDepth, m.recoveryTime, m.criticalServicesAffected, m.impactPercentage])
    await pool.query('DELETE FROM simulation_snapshots WHERE simulation_id = $1', [record.id])
    await pool.query('INSERT INTO simulation_snapshots (simulation_id, simulation_time, state_json, affected_service_count, cascade_depth) VALUES ($1,$2,$3,$4,$5)', [record.id, record.completedAt, JSON.stringify(record.finalStates), m.affectedServices, m.cascadeDepth])
    await pool.query('COMMIT')
    return true
  } catch (error) { await pool.query('ROLLBACK'); throw error }
}

export async function databaseSimulation(id: string): Promise<SimulationRecord | null | undefined> {
  const pool = await database()
  if (!pool) return undefined
  const simulation = await pool.query('SELECT * FROM simulations WHERE id = $1', [id])
  if (!simulation.rowCount) return null
  const [events, metrics, serviceCount] = await Promise.all([
    pool.query('SELECT simulation_time, service_id, event_type, previous_state, new_state, reason FROM simulation_events WHERE simulation_id = $1 ORDER BY simulation_time, created_at', [id]),
    pool.query('SELECT * FROM simulation_metrics WHERE simulation_id = $1', [id]),
    pool.query('SELECT COUNT(*)::int AS count FROM services'),
  ])
  const row = simulation.rows[0]
  const metric = metrics.rows[0]
  const parseJson = <T>(value: unknown): T => typeof value === 'string' ? JSON.parse(value) as T : value as T
  return {
    id: row.id,
    scenarioId: row.scenario_id,
    status: row.status,
    disruptions: parseJson<Disruption[]>(row.disruptions_json),
    events: events.rows.map((event) => ({ simulationTime: number(event.simulation_time), serviceId: event.service_id, eventType: event.event_type, ...(event.previous_state ? { previousState: event.previous_state as ServiceState } : {}), ...(event.new_state ? { newState: event.new_state as ServiceState } : {}), ...(event.reason ? { reason: event.reason } : {}) })),
    metrics: {
      affectedServices: number(metric?.affected_services ?? 0),
      cascadeDepth: number(metric?.cascade_depth ?? 0),
      recoveryTime: number(metric?.recovery_time ?? 0),
      criticalServicesAffected: number(metric?.critical_services_affected ?? 0),
      impactPercentage: number(metric?.impact_percentage ?? 0),
      totalServices: number(serviceCount.rows[0].count),
    },
    finalStates: parseJson<Record<string, ServiceState>>(row.final_state),
    completedAt: number(row.simulation_duration ?? 0),
    firstDisruptionTime: number(row.first_disruption_time),
    startedAt: row.started_at?.toISOString() ?? row.created_at.toISOString(),
    completedAtTs: row.completed_at?.toISOString() ?? null,
  }
}
