import type { NextFunction, Request, Response } from 'express'
import { AppError } from '../utils/AppError.js'
import { errorResponse } from '../utils/apiResponse.js'

export function notFoundHandler(_req: Request, res: Response) {
  res.status(404).json(errorResponse('NOT_FOUND', 'Resource was not found.'))
}

export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
) {
  // Keep Express's four-argument error-middleware signature while making
  // the intentionally unused callback explicit to the linter.
  void _next

  if (err instanceof AppError) {
    res.status(err.statusCode).json(errorResponse(err.code, err.message))
    return
  }

  console.error(err)
  res.status(500).json(errorResponse('INTERNAL_ERROR', 'An unexpected error occurred.'))
}
