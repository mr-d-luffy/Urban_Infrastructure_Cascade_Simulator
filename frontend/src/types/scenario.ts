export interface Scenario {
  id: string
  name: string
  description?: string
  seed: number
  durationSeconds: number
  tickSeconds: number
}

export interface ScenarioDisruption {
  serviceId: string
  startTime: number
  severity: number
  duration?: number
}
