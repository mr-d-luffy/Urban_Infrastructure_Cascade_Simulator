import { store } from '../repositories/memoryStore.js'
import { AppError } from '../utils/AppError.js'
import { databaseDependencies, databaseServices } from '../db/repository.js'

export async function listServices() {
  return (await databaseServices()) ?? store.services
}

export async function getServiceById(id: string) {
  const service = (await listServices()).find((item) => item.id === id)
  if (!service) {
    throw new AppError(404, 'SERVICE_NOT_FOUND', 'Service was not found.')
  }
  return service
}

export async function listDependencies() {
  return (await databaseDependencies()) ?? store.dependencies
}
