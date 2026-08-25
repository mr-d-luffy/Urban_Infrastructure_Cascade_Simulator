import dns from 'node:dns'
dns.setDefaultResultOrder('ipv4first')

import { readdir, readFile } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { getPool } from './pool.js'

const migrationsDirectory = join(dirname(fileURLToPath(import.meta.url)), '../../migrations')

async function migrate() {
  const pool = getPool()
  if (!pool) throw new Error('DATABASE_URL is required to run migrations.')

  await pool.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      name TEXT PRIMARY KEY,
      applied_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  `)

  const files = (await readdir(migrationsDirectory)).filter((file) => file.endsWith('.sql')).sort()
  for (const file of files) {
    const applied = await pool.query('SELECT 1 FROM schema_migrations WHERE name = $1', [file])
    if (applied.rowCount) continue
    const sql = await readFile(join(migrationsDirectory, file), 'utf8')
    await pool.query('BEGIN')
    try {
      await pool.query(sql)
      await pool.query('INSERT INTO schema_migrations (name) VALUES ($1)', [file])
      await pool.query('COMMIT')
      console.log(`Applied ${file}`)
    } catch (error) {
      await pool.query('ROLLBACK')
      throw error
    }
  }
  await pool.end()
}

migrate().catch((error: unknown) => {
  console.error(error)
  process.exitCode = 1
})
