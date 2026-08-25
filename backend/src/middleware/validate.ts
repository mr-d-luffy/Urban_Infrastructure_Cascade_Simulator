import { AppError } from '../utils/AppError.js'

function isNonEmptyString(value: unknown): value is string {
  return typeof value === 'string' && value.trim().length > 0
}

function isValidSeverity(value: unknown): value is number {
  return typeof value === 'number' && value >= 0 && value <= 1
}

export function validateCreateScenario(body: unknown) {
  if (!body || typeof body !== 'object') {
    throw new AppError(400, 'VALIDATION_ERROR', 'Request body is required.')
  }

  const data = body as Record<string, unknown>
  if (!isNonEmptyString(data.name)) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Scenario name is required.')
  }

  if (data.name.length > 160) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Scenario name is too long.')
  }

  if (data.disruptions !== undefined && !Array.isArray(data.disruptions)) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Disruptions must be an array.')
  }
}

export function validateUpdateScenario(body: unknown) {
  if (!body || typeof body !== 'object') {
    throw new AppError(400, 'VALIDATION_ERROR', 'Request body is required.')
  }

  const data = body as Record<string, unknown>
  if (data.name !== undefined && !isNonEmptyString(data.name)) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Scenario name must be a non-empty string.')
  }
}

export function validateRunSimulation(body: unknown) {
  if (!body || typeof body !== 'object') {
    throw new AppError(400, 'VALIDATION_ERROR', 'Request body is required.')
  }

  const data = body as Record<string, unknown>
  const hasScenario = isNonEmptyString(data.scenarioId)
  const hasDisruptions = Array.isArray(data.disruptions) && data.disruptions.length > 0

  if (!hasScenario && !hasDisruptions) {
    throw new AppError(
      400,
      'VALIDATION_ERROR',
      'Provide scenarioId or at least one disruption.',
    )
  }

  if (data.disruptions) {
    const disruptions = data.disruptions as unknown[]
    for (const disruption of disruptions) {
      if (!disruption || typeof disruption !== 'object') {
        throw new AppError(400, 'VALIDATION_ERROR', 'Invalid disruption entry.')
      }
      const entry = disruption as Record<string, unknown>
      if (!isNonEmptyString(entry.serviceId)) {
        throw new AppError(400, 'VALIDATION_ERROR', 'Disruption serviceId is required.')
      }
      if (entry.severity !== undefined && !isValidSeverity(entry.severity)) {
        throw new AppError(400, 'VALIDATION_ERROR', 'Disruption severity must be 0–1.')
      }
    }
  }
}

export function validateRecovery(body: unknown) {
  if (!body || typeof body !== 'object') {
    throw new AppError(400, 'VALIDATION_ERROR', 'Request body is required.')
  }

  const data = body as Record<string, unknown>
  if (!Array.isArray(data.serviceIds) || data.serviceIds.length === 0) {
    throw new AppError(
      400,
      'VALIDATION_ERROR',
      'At least one serviceId is required for recovery.',
    )
  }

  for (const serviceId of data.serviceIds) {
    if (!isNonEmptyString(serviceId)) {
      throw new AppError(400, 'VALIDATION_ERROR', 'Each serviceId must be a non-empty string.')
    }
  }
}

export function sanitizeScenarioName(name: string): string {
  return name.trim().slice(0, 160)
}
