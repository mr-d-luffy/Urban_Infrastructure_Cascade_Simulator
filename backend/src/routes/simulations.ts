import { Router } from 'express'
import {
  getEvents,
  getMetrics,
  getSimulation,
  getTimeline,
  postRecovery,
  postReset,
  postSimulation,
} from '../controllers/simulationController.js'
import { asyncHandler } from '../middleware/asyncHandler.js'
import { validateRecovery, validateRunSimulation } from '../middleware/validate.js'

export const simulationsRouter = Router()

simulationsRouter.post('/', asyncHandler(async (req, res) => {
  validateRunSimulation(req.body)
  await postSimulation(req, res)
}))
simulationsRouter.get('/:id', asyncHandler(getSimulation))
simulationsRouter.post('/:id/recovery', asyncHandler(async (req, res) => {
  validateRecovery(req.body)
  await postRecovery(req, res)
}))
simulationsRouter.post('/:id/reset', asyncHandler(postReset))
simulationsRouter.get('/:id/events', asyncHandler(getEvents))
simulationsRouter.get('/:id/metrics', asyncHandler(getMetrics))
simulationsRouter.get('/:id/timeline', asyncHandler(getTimeline))
