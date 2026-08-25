import { ArrowRight, Menu, Moon, Sun, X } from 'lucide-react'
import { useState } from 'react'

const NAV_ITEMS = ['CASCADE', 'NETWORK', 'SCENARIOS', 'ANALYTICS'] as const

interface CinematicNavProps {
  onEnterSimulator: () => void
  inverted?: boolean
  theme?: 'light' | 'dark'
  onToggleTheme?: () => void
}

export function CinematicNav({
  onEnterSimulator,
  inverted = true,
  theme = 'light',
  onToggleTheme,
}: CinematicNavProps) {
  const [menuOpen, setMenuOpen] = useState(false)

  const textClass = inverted ? 'text-white' : 'text-navy'
  const borderClass = inverted ? 'border-white/20' : 'border-navy/15'

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 border-b ${borderClass} backdrop-blur-sm ${
        inverted ? 'bg-navy/70' : 'bg-surface/90'
      }`}
    >
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-6">
        <p className={`text-sm font-medium tracking-cinematic ${textClass}`}>
          CASCADE SIMULATOR
        </p>

        <nav className="hidden items-center gap-8 lg:flex" aria-label="Primary">
          {NAV_ITEMS.map((item) => (
            <button
              key={item}
              type="button"
              className={`text-xs tracking-cinematic transition-opacity hover:opacity-70 ${textClass}`}
              onClick={onEnterSimulator}
            >
              {item}
            </button>
          ))}
        </nav>

        <div className="flex items-center gap-3">
          {onToggleTheme && (
            <button
              type="button"
              onClick={onToggleTheme}
              aria-label={theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'}
              className={`rounded-full p-2 transition-colors hover:bg-white/10 dark:hover:bg-navy/10 ${textClass}`}
            >
              {theme === 'dark' ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
            </button>
          )}

          <button
            type="button"
            onClick={onEnterSimulator}
            className={`hidden items-center gap-2 rounded-full px-5 py-2 text-xs font-medium tracking-wide transition-opacity hover:opacity-90 sm:inline-flex ${
              inverted
                ? 'bg-white text-navy'
                : 'border border-navy bg-transparent text-navy'
            }`}
          >
            RUN SIMULATION
            <ArrowRight className="h-4 w-4" aria-hidden="true" />
          </button>

          <button
            type="button"
            className={`inline-flex rounded-md p-2 lg:hidden ${textClass}`}
            aria-label={menuOpen ? 'Close menu' : 'Open menu'}
            onClick={() => setMenuOpen((open) => !open)}
          >
            {menuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
          </button>
        </div>
      </div>

      {menuOpen && (
        <nav
          className="border-t border-white/10 bg-navy px-6 py-6 lg:hidden"
          aria-label="Mobile"
        >
          <ul className="space-y-4">
            {NAV_ITEMS.map((item) => (
              <li key={item}>
                <button
                  type="button"
                  className="w-full text-left text-sm tracking-cinematic text-white"
                  onClick={() => {
                    setMenuOpen(false)
                    onEnterSimulator()
                  }}
                >
                  {item}
                </button>
              </li>
            ))}
            <li>
              <button
                type="button"
                className="inline-flex w-full items-center justify-center gap-2 rounded-full bg-white px-5 py-3 text-sm font-medium text-navy"
                onClick={() => {
                  setMenuOpen(false)
                  onEnterSimulator()
                }}
              >
                RUN SIMULATION
                <ArrowRight className="h-4 w-4" aria-hidden="true" />
              </button>
            </li>
          </ul>
        </nav>
      )}
    </header>
  )
}
