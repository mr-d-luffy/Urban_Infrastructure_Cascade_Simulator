import { describe, expect, it, vi, beforeEach } from 'vitest'
import { getScenarios, postScenario } from '../controllers/scenarioController.js'
import { createScenario, listScenarios } from '../services/scenarioService.js'
import { validateCreateScenario } from '../middleware/validate.js'
import { AppError } from '../utils/AppError.js'

// Mock the services layer
vi.mock('../services/scenarioService.js', () => ({
  listScenarios: vi.fn(),
  createScenario: vi.fn(),
  getScenarioById: vi.fn(),
  updateScenario: vi.fn(),
  deleteScenario: vi.fn(),
}))

describe('Backend Scenario Route Handlers & Validation', () => {
  const mockResponse = () => {
    const res: any = {}
    res.status = vi.fn().mockReturnValue(res)
    res.json = vi.fn().mockReturnValue(res)
    return res
  }

  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('getScenarios controller', () => {
    it('should return 200 with list of scenarios', async () => {
      const mockList = [{ id: '1', name: 'Scenario 1' }]
      vi.mocked(listScenarios).mockResolvedValueOnce(mockList as any)

      const req = {}
      const res = mockResponse()

      await getScenarios(req as any, res)

      expect(listScenarios).toHaveBeenCalled()
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        data: mockList,
        error: null,
      })
    })
  })

  describe('postScenario controller and validation', () => {
    it('should throw validation error if request body is empty or invalid', () => {
      expect(() => validateCreateScenario(null)).toThrow(AppError)
      expect(() => validateCreateScenario({})).toThrow(AppError)
      expect(() => validateCreateScenario({ name: '' })).toThrow(AppError)
    })

    it('should pass validation and call createScenario service', async () => {
      const mockScenario = { id: 'uuid-1', name: 'Power Failure Test', disruptions: [] }
      vi.mocked(createScenario).mockResolvedValueOnce(mockScenario as any)

      const req = {
        body: {
          name: 'Power Failure Test',
          disruptions: [],
        },
      }
      
      // Perform validation check (normally run in route wrapper)
      expect(() => validateCreateScenario(req.body)).not.toThrow()

      const res = mockResponse()
      await postScenario(req as any, res)

      expect(createScenario).toHaveBeenCalledWith(req.body)
      expect(res.status).toHaveBeenCalledWith(201)
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        data: mockScenario,
        error: null,
      })
    })
  })
})
