import type { Request, Response } from 'express'
import { buildTimeline, getSimulationMetrics } from '../services/metricsService.js'
import {
  applyRecovery,
  getSimulationById,
  getSimulationEvents,
  resetSimulation,
  runSimulationFromRequest,
} from '../services/simulationService.js'
import type { Disruption } from '../simulation/types.js'
import { paramId } from '../utils/params.js'
import { successResponse } from '../utils/apiResponse.js'

export async function postSimulation(req: Request, res: Response) {
  const body = req.body as { scenarioId?: string; disruptions?: Disruption[] }
  const simulation = await runSimulationFromRequest(body)
  res.status(201).json(successResponse(simulation))
}

export async function getSimulation(req: Request, res: Response) {
  res.json(successResponse((await getSimulationById(paramId(req.params.id))).record))
}

export async function postRecovery(req: Request, res: Response) {
  const body = req.body as { serviceIds: string[] }
  const simulation = await applyRecovery(paramId(req.params.id), body.serviceIds)
  res.json(successResponse(simulation))
}

export async function postReset(req: Request, res: Response) {
  const simulation = await resetSimulation(paramId(req.params.id))
  res.json(successResponse(simulation))
}

export async function getEvents(req: Request, res: Response) {
  res.json(successResponse(await getSimulationEvents(paramId(req.params.id))))
}

export async function getMetrics(req: Request, res: Response) {
  const simulation = (await getSimulationById(paramId(req.params.id))).record
  res.json(successResponse(getSimulationMetrics(simulation)))
}

export async function getTimeline(req: Request, res: Response) {
  const simulation = (await getSimulationById(paramId(req.params.id))).record
  res.json(successResponse(buildTimeline(simulation)))
}
