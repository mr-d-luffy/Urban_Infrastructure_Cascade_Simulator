import pg from 'pg'
import { env } from '../config/env.js'

const { Pool } = pg

let pool: pg.Pool | null = null

export function getPool(): pg.Pool | null {
  if (!env.databaseUrl) return null
  if (!pool) {
    if (env.nodeEnv === 'production') {
      process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0'
    }
    const useSsl = env.databaseUrl.includes('sslmode=') || env.databaseUrl.includes('supabase.com')
    pool = new Pool({
      connectionString: env.databaseUrl,
      ssl: useSsl ? { rejectUnauthorized: false } : undefined,
    })
  }
  return pool
}

export async function checkDatabaseConnection(): Promise<boolean> {
  const dbPool = getPool()
  if (!dbPool) return false
  try {
    await dbPool.query('SELECT 1')
    return true
  } catch {
    return false
  }
}

export async function closePool(): Promise<void> {
  if (pool) {
    await pool.end()
    pool = null
  }
}
