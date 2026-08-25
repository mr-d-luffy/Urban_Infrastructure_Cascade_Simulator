import type { NextFunction, Request, Response } from 'express'

export function asyncHandler(
  handler: (req: Request, res: Response, next: NextFunction) => void | Promise<void>,
) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(handler(req, res, next)).catch(next)
  }
}
