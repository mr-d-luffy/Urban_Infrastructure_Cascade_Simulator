import type { Request, Response } from 'express'
import { listDependencies, listServices, getServiceById } from '../services/graphService.js'
import { paramId } from '../utils/params.js'
import { successResponse } from '../utils/apiResponse.js'

export async function getServices(_req: Request, res: Response) {
  res.json(successResponse(await listServices()))
}

export async function getService(req: Request, res: Response) {
  res.json(successResponse(await getServiceById(paramId(req.params.id))))
}

export async function getDependencies(_req: Request, res: Response) {
  res.json(successResponse(await listDependencies()))
}
