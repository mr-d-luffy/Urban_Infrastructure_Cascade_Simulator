import dns from 'node:dns'
dns.setDefaultResultOrder('ipv4first')

import cors from 'cors'
import express from 'express'
import { env } from './config/env.js'
import { checkDatabaseConnection } from './db/pool.js'
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js'
import { apiRouter } from './routes/index.js'

const app = express()

const allowedOrigin = env.corsOrigin.endsWith('/') ? env.corsOrigin.slice(0, -1) : env.corsOrigin
app.use(cors({ origin: allowedOrigin }))
app.use(express.json({ limit: '1mb' }))

app.use('/api', apiRouter)

app.use(notFoundHandler)
app.use(errorHandler)

async function start() {
  const databaseConnected = await checkDatabaseConnection()
  const server = app.listen(env.port, '0.0.0.0', () => {
    console.log(`Cascade simulator API listening on http://0.0.0.0:${env.port}`)
    console.log(
      databaseConnected
        ? 'PostgreSQL connected — Phase 8 migrations can enable persistent storage.'
        : 'Using in-memory storage — set DATABASE_URL for PostgreSQL connection.',
    )
  })

  server.on('error', (err: NodeJS.ErrnoException) => {
    if (err.code === 'EADDRINUSE') {
      console.error(`Port ${env.port} is already in use.`)
      process.exit(1)
    }
    throw err
  })
}

start()
