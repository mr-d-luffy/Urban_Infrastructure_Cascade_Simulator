import dns from 'node:dns'
dns.setDefaultResultOrder('ipv4first')

import { getPool } from './pool.js'

const services = [
  ['Power Grid', 'power-grid', 'Energy', 5, 'Primary electrical distribution for the city core.', 6],
  ['Hospital', 'hospital', 'Healthcare', 5, 'Regional hospital providing critical care services.', 6],
  ['Water Supply', 'water-supply', 'Water', 4, 'Municipal water treatment and distribution network.', 5],
  ['Public Transport', 'public-transport', 'Transport', 4, 'Bus and rail transit connecting districts.', 5],
  ['Communication Network', 'communication-network', 'Communication', 4, 'City-wide telecom and emergency communications backbone.', 5],
  ['Emergency Services', 'emergency-services', 'Emergency', 5, 'Fire, police, and medical emergency response coordination.', 6],
  ['Residential Areas', 'residential-areas', 'Residential', 3, 'Dense residential districts dependent on utility services.', 4],
  ['Waste Management', 'waste-management', 'Waste', 2, 'Sanitation and waste collection operations.', 4],
] as const

const dependencies = [
  ['power-grid', 'hospital', 1],
  ['power-grid', 'water-supply', 1],
  ['power-grid', 'public-transport', 1],
  ['power-grid', 'communication-network', 1],
  ['hospital', 'emergency-services', 1],
  ['public-transport', 'emergency-services', 0.9],
  ['water-supply', 'residential-areas', 1],
  ['power-grid', 'waste-management', 0.7],
] as const

async function seed() {
  const pool = getPool()
  if (!pool) throw new Error('DATABASE_URL is required to seed the database.')

  await pool.query('BEGIN')
  try {
    for (const [name, slug, category, criticality, description, recoveryDuration] of services) {
      await pool.query(
        `INSERT INTO services (name, slug, category, criticality, description, recovery_duration)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (slug) DO UPDATE SET
           name = EXCLUDED.name, category = EXCLUDED.category, criticality = EXCLUDED.criticality,
           description = EXCLUDED.description, recovery_duration = EXCLUDED.recovery_duration,
           updated_at = CURRENT_TIMESTAMP`,
        [name, slug, category, criticality, description, recoveryDuration],
      )
    }

    for (const [sourceSlug, targetSlug, strength] of dependencies) {
      await pool.query(
        `INSERT INTO dependencies (source_service_id, target_service_id, dependency_strength)
         SELECT source.id, target.id, $3 FROM services AS source CROSS JOIN services AS target
         WHERE source.slug = $1 AND target.slug = $2
         ON CONFLICT (source_service_id, target_service_id) DO UPDATE
           SET dependency_strength = EXCLUDED.dependency_strength`,
        [sourceSlug, targetSlug, strength],
      )
    }

    const existing = await pool.query<{ id: string }>(
      'SELECT id FROM scenarios WHERE name = $1 ORDER BY created_at LIMIT 1',
      ['City Power Failure'],
    )
    const scenarioId = existing.rows[0]?.id ?? (
      await pool.query<{ id: string }>(
        `INSERT INTO scenarios (name, description, seed, duration_seconds, tick_seconds)
         VALUES ($1, $2, $3, $4, $5) RETURNING id`,
        ['City Power Failure', 'Power grid fails at T+0 and cascades through dependent services.', 42003, 60, 1],
      )
    ).rows[0].id

    await pool.query('DELETE FROM scenario_disruptions WHERE scenario_id = $1', [scenarioId])
    await pool.query(
      `INSERT INTO scenario_disruptions (scenario_id, service_id, start_time, severity)
       SELECT $1, id, 0, 1 FROM services WHERE slug = 'power-grid'`,
      [scenarioId],
    )
    await pool.query('COMMIT')
    console.log('Seeded deterministic city infrastructure and demo scenario.')
  } catch (error) {
    await pool.query('ROLLBACK')
    throw error
  } finally {
    await pool.end()
  }
}

seed().catch((error: unknown) => {
  console.error(error)
  process.exitCode = 1
})
