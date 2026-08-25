import { Router } from 'express'
import { checkDatabaseConnection } from '../db/pool.js'
import { dependenciesRouter, servicesRouter } from './graph.js'
import { scenariosRouter } from './scenarios.js'
import { simulationsRouter } from './simulations.js'
import { successResponse } from '../utils/apiResponse.js'

export const apiRouter = Router()

apiRouter.get('/health', async (_req, res) => {
  const databaseConnected = await checkDatabaseConnection()
  res.json(
    successResponse({
      status: 'ok',
      storage: databaseConnected ? 'postgresql' : 'memory',
      databaseConnected,
    }),
  )
})

apiRouter.use('/services', servicesRouter)
apiRouter.use('/dependencies', dependenciesRouter)
apiRouter.use('/scenarios', scenariosRouter)
apiRouter.use('/simulations', simulationsRouter)
