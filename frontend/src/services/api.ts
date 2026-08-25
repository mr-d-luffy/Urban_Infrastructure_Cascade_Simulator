const API_BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:5000'

export interface ApiResponse<T> {
  success: boolean
  data: T | null
  error: { code: string; message: string } | null
}

export interface ApiService {
  id: string
  name: string
  slug: string
  category: string
  criticality: number
  defaultState: string
  description?: string
  recoveryDuration: number
}

export interface ApiDependency {
  id: string
  sourceServiceId: string
  targetServiceId: string
  dependencyStrength: number
}

export interface ApiScenario {
  id: string
  name: string
  description: string | null
  seed: number
  durationSeconds: number
  tickSeconds: number
  disruptions: Array<{ serviceId: string; startTime: number; severity: number }>
}

export interface ApiSimulation {
  id: string
  scenarioId: string | null
  status: string
  events: Array<{
    simulationTime: number
    serviceId: string
    eventType: string
    previousState?: string
    newState?: string
    reason?: string
  }>
  metrics: {
    affectedServices: number
    cascadeDepth: number
    recoveryTime: number
    impactPercentage: number
    criticalServicesAffected: number
    totalServices: number
  }
  finalStates: Record<string, string>
  completedAt: number
}

async function request<T>(path: string, init?: RequestInit): Promise<ApiResponse<T>> {
  try {
    const response = await fetch(`${API_BASE}${path}`, {
      headers: { 'Content-Type': 'application/json', ...init?.headers },
      ...init,
    })
    if (!response.ok) {
      const errBody = await response.json().catch(() => null)
      return {
        success: false,
        data: null,
        error: {
          code: errBody?.error?.code || 'HTTP_ERROR',
          message: errBody?.error?.message || `HTTP error! status: ${response.status}`,
        },
      }
    }
    return await (response.json() as Promise<ApiResponse<T>>)
  } catch (err) {
    return {
      success: false,
      data: null,
      error: {
        code: 'NETWORK_ERROR',
        message: err instanceof Error ? err.message : 'Network error or backend unreachable',
      },
    }
  }
}

export const api = {
  health: () =>
    request<{ status: string; storage: string; databaseConnected: boolean }>('/api/health'),

  getServices: () => request<ApiService[]>('/api/services'),
  getService: (id: string) => request<ApiService>(`/api/services/${id}`),
  getDependencies: () => request<ApiDependency[]>('/api/dependencies'),

  getScenarios: () => request<ApiScenario[]>('/api/scenarios'),
  getScenario: (id: string) => request<ApiScenario>(`/api/scenarios/${id}`),
  createScenario: (body: Partial<ApiScenario> & { name: string }) =>
    request<ApiScenario>('/api/scenarios', { method: 'POST', body: JSON.stringify(body) }),
  updateScenario: (id: string, body: Partial<ApiScenario>) =>
    request<ApiScenario>(`/api/scenarios/${id}`, { method: 'PUT', body: JSON.stringify(body) }),
  deleteScenario: (id: string) =>
    request<{ deleted: boolean }>(`/api/scenarios/${id}`, { method: 'DELETE' }),

  runSimulation: (body: { scenarioId?: string; disruptions?: ApiScenario['disruptions'] }) =>
    request<ApiSimulation>('/api/simulations', { method: 'POST', body: JSON.stringify(body) }),
  getSimulation: (id: string) => request<ApiSimulation>(`/api/simulations/${id}`),
  recoverSimulation: (id: string, serviceIds: string[]) =>
    request<ApiSimulation>(`/api/simulations/${id}/recovery`, {
      method: 'POST',
      body: JSON.stringify({ serviceIds }),
    }),
  resetSimulation: (id: string) =>
    request<ApiSimulation>(`/api/simulations/${id}/reset`, { method: 'POST' }),
  getSimulationEvents: (id: string) =>
    request<ApiSimulation['events']>(`/api/simulations/${id}/events`),
  getSimulationMetrics: (id: string) =>
    request<ApiSimulation['metrics']>(`/api/simulations/${id}/metrics`),
  getSimulationTimeline: (id: string) =>
    request<{ markers: unknown[]; events: ApiSimulation['events'] }>(
      `/api/simulations/${id}/timeline`,
    ),
}
