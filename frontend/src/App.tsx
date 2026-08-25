import { CinematicHero } from '@/components/cinematic/CinematicHero'
import { CinematicNav } from '@/components/cinematic/CinematicNav'
import { SimulatorWorkspace } from '@/components/simulation/SimulatorWorkspace'
import { useTheme } from '@/hooks/useTheme'
import { useCallback } from 'react'

function App() {
  const { theme, toggleTheme } = useTheme()

  const enterSimulator = useCallback(() => {
    document.getElementById('simulator')?.scrollIntoView({ behavior: 'smooth' })
  }, [])

  return (
    <>
      <CinematicNav
        onEnterSimulator={enterSimulator}
        theme={theme}
        onToggleTheme={toggleTheme}
      />
      <main>
        <CinematicHero onEnterSimulator={enterSimulator} />
        <SimulatorWorkspace />
      </main>
    </>
  )
}

export default App
