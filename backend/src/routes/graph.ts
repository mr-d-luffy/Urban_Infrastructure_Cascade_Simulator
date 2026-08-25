import { Router } from 'express'
import { getDependencies, getService, getServices } from '../controllers/graphController.js'
import { asyncHandler } from '../middleware/asyncHandler.js'

export const servicesRouter = Router()

servicesRouter.get('/', asyncHandler(getServices))
servicesRouter.get('/:id', asyncHandler(getService))

export const dependenciesRouter = Router()

dependenciesRouter.get('/', asyncHandler(getDependencies))
