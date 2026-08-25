import { useEffect, useState } from 'react'

interface ScrollProgressOptions {
  start?: number
  end?: number
}

export function useScrollProgress(
  ref: React.RefObject<HTMLElement | null>,
  options: ScrollProgressOptions = {},
) {
  const { start = 0, end = 1 } = options
  const [progress, setProgress] = useState(0)

  useEffect(() => {
    const element = ref.current
    if (!element) return

    const updateProgress = () => {
      const rect = element.getBoundingClientRect()
      const viewportHeight = window.innerHeight
      const scrollable = element.offsetHeight - viewportHeight

      if (scrollable <= 0) {
        setProgress(0)
        return
      }

      const scrolled = Math.min(Math.max(-rect.top, 0), scrollable)
      const raw = scrolled / scrollable
      const mapped = start + raw * (end - start)
      setProgress(Math.min(Math.max(mapped, 0), 1))
    }

    updateProgress()
    window.addEventListener('scroll', updateProgress, { passive: true })
    window.addEventListener('resize', updateProgress)

    return () => {
      window.removeEventListener('scroll', updateProgress)
      window.removeEventListener('resize', updateProgress)
    }
  }, [ref, start, end])

  return progress
}

export function usePrefersReducedMotion() {
  const [reduced, setReduced] = useState(false)

  useEffect(() => {
    const media = window.matchMedia('(prefers-reduced-motion: reduce)')
    const update = () => setReduced(media.matches)
    update()
    media.addEventListener('change', update)
    return () => media.removeEventListener('change', update)
  }, [])

  return reduced
}
