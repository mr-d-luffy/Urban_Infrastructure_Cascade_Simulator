/* eslint-disable react-hooks/set-state-in-effect */
import { api, type ApiScenario } from '@/services/api'
import type { Disruption } from '@/simulation/types'
import { Copy, Pencil, Play, Plus, Trash2 } from 'lucide-react'
import { useEffect, useState } from 'react'

interface ScenarioManagerProps {
  disruptions: Disruption[]
  disabled: boolean
  onLoad: (disruptions: Disruption[]) => void
}

export function ScenarioManager({ disruptions, disabled, onLoad }: ScenarioManagerProps) {
  const [scenarios, setScenarios] = useState<ApiScenario[]>([])
  const [name, setName] = useState('')
  const [editingId, setEditingId] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  const refresh = async () => {
    setLoading(true)
    try {
      const response = await api.getScenarios()
      if (response.success && response.data) setScenarios(response.data)
      else setError(response.error?.message ?? 'Could not load scenarios.')
    } catch {
      setError('Could not reach the scenario service.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { void refresh() }, [])

  const save = async () => {
    if (!name.trim()) return setError('Enter a scenario name.')
    const response = editingId
      ? await api.updateScenario(editingId, { name: name.trim(), disruptions })
      : await api.createScenario({ name: name.trim(), disruptions })
    if (!response.success) return setError(response.error?.message ?? 'Could not save scenario.')
    setName('')
    setEditingId(null)
    setError(null)
    await refresh()
  }

  const duplicate = async (scenario: ApiScenario) => {
    const response = await api.createScenario({ ...scenario, name: `${scenario.name} copy` })
    if (!response.success) return setError(response.error?.message ?? 'Could not duplicate scenario.')
    await refresh()
  }

  const remove = async (id: string) => {
    const response = await api.deleteScenario(id)
    if (!response.success) return setError(response.error?.message ?? 'Could not delete scenario.')
    await refresh()
  }

  const edit = (scenario: ApiScenario) => {
    setEditingId(scenario.id)
    setName(scenario.name)
    onLoad(scenario.disruptions)
    setError(null)
  }

  return <div className="rounded-lg border border-navy/10 dark:border-white/10 bg-white dark:bg-[#132230] p-5">
    <h3 className="text-xs tracking-cinematic text-neutral dark:text-neutral/80">Saved scenarios</h3>
    <div className="mt-3 flex gap-2">
      <input value={name} onChange={(event) => setName(event.target.value)} placeholder="Scenario name" disabled={disabled || loading} className="min-w-0 flex-1 rounded-md border border-navy/15 dark:border-white/20 px-2 py-2 text-xs text-navy dark:text-white dark:bg-navy/40" />
      <button type="button" onClick={() => void save()} disabled={disabled || loading} className="rounded-md border border-navy/15 dark:border-white/20 px-2 text-navy dark:text-white dark:hover:bg-navy/40 disabled:opacity-50" aria-label={editingId ? 'Update scenario' : 'Save scenario'}><Plus className="h-4 w-4" /></button>
    </div>
    {error && <p role="alert" className="mt-2 text-xs text-critical">{error}</p>}
    {loading ? <p className="mt-3 text-xs text-neutral dark:text-neutral/80" role="status">Loading scenarios…</p> : scenarios.length === 0 ? <p className="mt-3 text-xs text-neutral dark:text-neutral/80">No saved scenarios yet. Save the current disruption selection to create one.</p> : <ul className="mt-3 max-h-52 space-y-2 overflow-y-auto">
      {scenarios.map((scenario) => <li key={scenario.id} className="rounded-md border border-navy/10 dark:border-white/10 p-2">
        <p className="truncate text-xs font-medium text-navy dark:text-white">{scenario.name}</p>
        <p className="mt-1 text-[10px] text-neutral dark:text-neutral/60">{scenario.disruptions.length} disruptions</p>
        <div className="mt-2 flex gap-2">
          <button type="button" disabled={disabled} onClick={() => onLoad(scenario.disruptions)} className="text-xs text-navy dark:text-slate-300 hover:opacity-85 disabled:opacity-50"><Play className="mr-1 inline h-3 w-3" />Load</button>
          <button type="button" disabled={disabled} onClick={() => edit(scenario)} className="text-xs text-navy dark:text-slate-300 hover:opacity-85 disabled:opacity-50"><Pencil className="mr-1 inline h-3 w-3" />Edit</button>
          <button type="button" disabled={disabled} onClick={() => void duplicate(scenario)} className="text-xs text-navy dark:text-slate-300 hover:opacity-85 disabled:opacity-50"><Copy className="mr-1 inline h-3 w-3" />Copy</button>
          <button type="button" disabled={disabled} onClick={() => void remove(scenario.id)} className="text-xs text-critical hover:opacity-85 disabled:opacity-50"><Trash2 className="mr-1 inline h-3 w-3" />Delete</button>
        </div>
      </li>)}
    </ul>}
  </div>
}
