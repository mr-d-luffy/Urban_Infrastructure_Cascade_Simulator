# Design System --- Urban Infrastructure Cascade Simulator

## 1. Design Direction

The product should feel like:

**Cinematic + Technical + Premium + Calm + Data-driven**

Avoid the generic "admin dashboard" appearance.

The first impression should feel like a high-end infrastructure
visualization product. The simulator should then transition into a
precise technical interface.

## 2. Visual Concept

``` text
CINEMATIC CITY
      ↓
INFRASTRUCTURE NETWORK
      ↓
SIMULATION
      ↓
CASCADE ANALYTICS
```

## 3. Color System

### Primary Navy

``` text
#1D3045
```

Use for: - Primary text on light backgrounds. - Navigation. - Buttons. -
Infrastructure UI accents.

### Background

``` text
#F5F7F8
```

Use for light application surfaces.

### White

``` text
#FFFFFF
```

Use for: - Dark cinematic scenes. - Text on dark surfaces. - Filled
action controls.

### Status Colors

Success:

``` text
#2E8B57
```

Warning:

``` text
#D49A2A
```

Critical:

``` text
#C94B4B
```

Degraded:

``` text
#C98A35
```

Neutral:

``` text
#7B8794
```

Status colors must be used consistently and not as decoration.

## 4. Typography

Primary font:

``` text
Helvetica Neue
```

Fallback:

``` text
Helvetica, Arial, sans-serif
```

Cinematic hero: - Light weight. - Large uppercase typography. - Generous
line-height. - Wide tracking.

Application UI: - Medium/regular weight. - Compact labels. - Clear
numerical hierarchy.

## 5. Layout

### Cinematic Section

``` text
100vw × 100vh
```

The cinematic introduction may use a long scroll track with a sticky
viewport.

### Simulator

Desktop:

``` text
┌──────────────┬──────────────────────┬──────────────┐
│ Controls     │ Infrastructure Graph │ Analytics    │
│ 25%          │ 50%                  │ 25%          │
└──────────────┴──────────────────────┴──────────────┘
```

Mobile:

``` text
Graph
  ↓
Metrics
  ↓
Controls
  ↓
Timeline
```

## 6. Navigation

Desktop:

``` text
CASCADE
NETWORK
SCENARIOS
ANALYTICS
```

Right:

``` text
[ RUN SIMULATION ]
```

Mobile: - Hamburger menu. - Full-screen navigation overlay.

## 7. Hero Copy

Primary:

> WHEN ONE SYSTEM FAILS, THE CITY FOLLOWS.

Secondary:

> Simulate. Understand. Recover.

Keep hero copy minimal.

## 8. Graph Design

Nodes should be: - Rounded. - Compact. - Clearly labeled. -
Status-aware.

Example:

``` text
┌─────────────────────┐
│ ⚡ Power Grid       │
│ ● HEALTHY           │
└─────────────────────┘
```

Failed:

``` text
┌─────────────────────┐
│ ⚡ Power Grid       │
│ ● FAILED            │
└─────────────────────┘
```

Edges: - Thin by default. - Directional. - Animated only during
propagation. - Never overwhelm labels.

## 9. Simulation Animation

Failure propagation:

``` text
Healthy
   ↓
Degraded
   ↓
Failed
```

Recovery:

``` text
Failed
   ↓
Recovering
   ↓
Recovered
```

Animation must communicate cause → effect.

## 10. Metrics Cards

Example:

``` text
AFFECTED SERVICES
07
```

``` text
CASCADE DEPTH
04
```

``` text
RECOVERY TIME
18m 32s
```

``` text
SYSTEM IMPACT
64%
```

Use large numbers and small uppercase labels.

## 11. Timeline

Minimal horizontal timeline:

``` text
Failure ─── Propagation ─── Recovery ─── Stable
  00:00         00:08          00:18       00:31
```

Use hover/click to inspect events.

## 12. Buttons

Primary:

``` text
RUN SIMULATION →
```

Secondary: - Outline. - Transparent. - Navy border.

Circular controls may be used in cinematic sections.

## 13. Cards

Avoid excessive cards.

Prefer: - Thin borders. - Small radius. - Large whitespace. - Strong
typography.

## 14. Responsive Breakpoints

``` text
Mobile:  < 640px
Tablet:  640px–1023px
Desktop: 1024px+
Large:   1280px+
```

On mobile: - Graph must remain usable. - Sidebars become stacked
sections. - Controls use full width. - Metrics become 2-column or
1-column. - Cinematic animation respects reduced-motion.

## 15. Accessibility

-   Minimum readable contrast.
-   Keyboard-accessible controls.
-   Visible focus states.
-   Status should never be communicated by color alone.
-   Support `prefers-reduced-motion`.
-   Buttons require accessible labels.

## 16. Design Rule

Do not add visual elements merely because they look impressive. Every
visual element must improve: - Understanding. - Navigation. - Simulation
comprehension. - Data interpretation.
