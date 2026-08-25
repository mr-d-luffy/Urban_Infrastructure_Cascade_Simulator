import { usePrefersReducedMotion, useScrollProgress } from '@/hooks/useVideoScrub'
import { ArrowDown } from 'lucide-react'
import { useRef } from 'react'

interface CinematicHeroProps {
  onEnterSimulator: () => void
}

const STAGES = [
  { label: 'CITY', threshold: 0 },
  { label: 'NETWORK', threshold: 0.25 },
  { label: 'FAILURE', threshold: 0.5 },
  { label: 'CASCADE', threshold: 0.75 },
  { label: 'SIMULATION', threshold: 1 },
] as const

export function CinematicHero({ onEnterSimulator }: CinematicHeroProps) {
  const trackRef = useRef<HTMLDivElement>(null)
  const progress = useScrollProgress(trackRef)
  const reducedMotion = usePrefersReducedMotion()

  const activeStage =
    STAGES.reduce(
      (current, stage) => (progress >= stage.threshold ? stage : current),
      STAGES[0],
    ) ?? STAGES[0]

  const networkOpacity = reducedMotion ? 1 : Math.min(progress * 2.5, 1)
  const failurePulse = reducedMotion ? 0.35 : Math.max(0, (progress - 0.45) * 2)
  const cascadeLines = reducedMotion ? 0.6 : Math.max(0, (progress - 0.65) * 3)

  return (
    <section ref={trackRef} className="relative h-[420vh]" aria-label="Introduction">
      <div className="sticky top-0 h-screen overflow-hidden bg-navy">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_20%,rgba(255,255,255,0.08),transparent_55%)]" />

        <div
          className="absolute inset-0 transition-opacity duration-700"
          style={{ opacity: 1 - progress * 0.35 }}
          aria-hidden="true"
        >
          <div className="absolute bottom-0 left-1/2 h-[55%] w-[120%] -translate-x-1/2 bg-gradient-to-t from-white/10 to-transparent" />
          <div className="absolute bottom-[18%] left-[12%] h-24 w-16 bg-white/10" />
          <div className="absolute bottom-[22%] left-[22%] h-36 w-20 bg-white/12" />
          <div className="absolute bottom-[16%] left-[34%] h-44 w-24 bg-white/14" />
          <div className="absolute bottom-[20%] right-[28%] h-40 w-20 bg-white/12" />
          <div className="absolute bottom-[14%] right-[14%] h-52 w-28 bg-white/16" />
        </div>

        <div
          className="absolute inset-0 flex items-center justify-center transition-opacity duration-700"
          style={{ opacity: networkOpacity }}
          aria-hidden="true"
        >
          <svg viewBox="0 0 800 500" className="h-[55vh] w-[min(90vw,760px)] text-white/70">
            <circle cx="400" cy="80" r="10" fill="currentColor" />
            <circle cx="220" cy="220" r="8" fill="currentColor" />
            <circle cx="580" cy="220" r="8" fill="currentColor" />
            <circle cx="320" cy="360" r="8" fill="currentColor" />
            <circle cx="480" cy="360" r="8" fill="currentColor" />
            <circle cx="400" cy="430" r="10" fill="currentColor" />
            <line x1="400" y1="90" x2="220" y2="212" stroke="currentColor" strokeWidth="1.5" />
            <line x1="400" y1="90" x2="580" y2="212" stroke="currentColor" strokeWidth="1.5" />
            <line x1="220" y1="228" x2="320" y2="352" stroke="currentColor" strokeWidth="1.5" />
            <line x1="580" y1="228" x2="480" y2="352" stroke="currentColor" strokeWidth="1.5" />
            <line x1="320" y1="368" x2="400" y2="420" stroke="currentColor" strokeWidth="1.5" />
            <line x1="480" y1="368" x2="400" y2="420" stroke="currentColor" strokeWidth="1.5" />
          </svg>
        </div>

        <div
          className="pointer-events-none absolute inset-0 bg-critical/20 transition-opacity duration-500"
          style={{ opacity: failurePulse }}
          aria-hidden="true"
        />

        <div
          className="pointer-events-none absolute inset-0"
          style={{ opacity: cascadeLines }}
          aria-hidden="true"
        >
          {[...Array(6)].map((_, index) => (
            <div
              key={index}
              className="absolute h-px bg-gradient-to-r from-transparent via-warning to-transparent"
              style={{
                top: `${20 + index * 12}%`,
                left: `${8 + index * 4}%`,
                right: `${8 + index * 3}%`,
                transform: `translateY(${index * 6}px)`,
              }}
            />
          ))}
        </div>

        <div className="relative z-10 flex h-full flex-col items-center justify-center px-6 pt-16 text-center text-white">
          <p className="mb-6 text-xs tracking-cinematic text-white/70">{activeStage.label}</p>
          <h1 className="max-w-4xl text-3xl font-light leading-tight tracking-cinematic sm:text-5xl lg:text-6xl">
            WHEN ONE SYSTEM FAILS,
            <br />
            THE CITY FOLLOWS.
          </h1>
          <p className="mt-6 max-w-xl text-sm tracking-wide text-white/75 sm:text-base">
            Simulate. Understand. Recover.
          </p>

          <div className="mt-10 flex flex-col items-center gap-4 sm:flex-row">
            <button
              type="button"
              onClick={onEnterSimulator}
              className="inline-flex items-center gap-2 rounded-full bg-white px-6 py-3 text-sm font-medium tracking-wide text-navy transition-opacity hover:opacity-90"
            >
              ENTER SIMULATOR
            </button>
            <a
              href="#simulator"
              className="inline-flex items-center gap-2 text-sm tracking-wide text-white/80 transition-opacity hover:opacity-70"
            >
              Scroll to explore
              <ArrowDown className="h-4 w-4" aria-hidden="true" />
            </a>
          </div>

          <div className="absolute bottom-10 left-1/2 w-[min(90vw,520px)] -translate-x-1/2">
            <div className="mb-2 flex justify-between text-[10px] tracking-cinematic text-white/50">
              {STAGES.map((stage) => (
                <span key={stage.label}>{stage.label}</span>
              ))}
            </div>
            <div className="h-px bg-white/20">
              <div
                className="h-px bg-white transition-all duration-300"
                style={{ width: `${progress * 100}%` }}
              />
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
