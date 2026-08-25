import { Router } from 'express'
import {
  getScenario,
  getScenarios,
  postScenario,
  putScenario,
  removeScenario,
} from '../controllers/scenarioController.js'
import { asyncHandler } from '../middleware/asyncHandler.js'
import { validateCreateScenario, validateUpdateScenario } from '../middleware/validate.js'

export const scenariosRouter = Router()

scenariosRouter.get('/', asyncHandler(getScenarios))
scenariosRouter.get('/:id', asyncHandler(getScenario))
scenariosRouter.post('/', asyncHandler(async (req, res) => {
  validateCreateScenario(req.body)
  await postScenario(req, res)
}))
scenariosRouter.put('/:id', asyncHandler(async (req, res) => {
  validateUpdateScenario(req.body)
  await putScenario(req, res)
}))
scenariosRouter.delete('/:id', asyncHandler(removeScenario))
