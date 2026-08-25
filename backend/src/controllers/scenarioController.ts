import type { Request, Response } from 'express'
import {
  createScenario,
  deleteScenario,
  getScenarioById,
  listScenarios,
  updateScenario,
} from '../services/scenarioService.js'
import type { Disruption } from '../simulation/types.js'
import { paramId } from '../utils/params.js'
import { successResponse } from '../utils/apiResponse.js'

export async function getScenarios(_req: Request, res: Response) {
  res.json(successResponse(await listScenarios()))
}

export async function getScenario(req: Request, res: Response) {
  res.json(successResponse(await getScenarioById(paramId(req.params.id))))
}

export async function postScenario(req: Request, res: Response) {
  const body = req.body as {
    name: string
    description?: string
    seed?: number
    durationSeconds?: number
    tickSeconds?: number
    disruptions?: Disruption[]
  }
  const scenario = await createScenario(body)
  res.status(201).json(successResponse(scenario))
}

export async function putScenario(req: Request, res: Response) {
  const body = req.body as Partial<{
    name: string
    description: string
    seed: number
    durationSeconds: number
    tickSeconds: number
    disruptions: Disruption[]
  }>
  const scenario = await updateScenario(paramId(req.params.id), body)
  res.json(successResponse(scenario))
}

export async function removeScenario(req: Request, res: Response) {
  await deleteScenario(paramId(req.params.id))
  res.json(successResponse({ deleted: true }))
}
