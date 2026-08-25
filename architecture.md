# Architecture --- Urban Infrastructure Cascade Simulator

## 1. Architecture Overview

The application uses a three-layer architecture:

``` text
Presentation Layer
        ↓
Application / Simulation API
        ↓
Persistence Layer
```

The frontend is responsible for visualization and user interaction. The
backend manages scenarios, simulation execution, validation, and
persistence. The database stores infrastructure graphs, scenarios,
events, and results.

## 2. Recommended Stack

### Frontend

-   Vite
-   React 18
-   TypeScript
-   Tailwind CSS 3
-   lucide-react
-   React Flow or a custom SVG/canvas graph layer
-   Web APIs for animation and scroll interaction

### Backend

-   Node.js
-   Express
-   TypeScript
-   REST API

### Database

-   PostgreSQL

### Development

-   Git
-   GitHub
-   ESLint
-   Prettier
-   dotenv

## 3. High-Level Architecture

``` text
                    ┌─────────────────────┐
                    │   React Frontend    │
                    │                     │
                    │ Cinematic Landing   │
                    │ Graph Visualizer    │
                    │ Controls            │
                    │ Timeline            │
                    │ Analytics           │
                    └──────────┬──────────┘
                               │ REST
                               ▼
                    ┌─────────────────────┐
                    │   Express API       │
                    │                     │
                    │ Scenario Service    │
                    │ Graph Service       │
                    │ Simulation Engine   │
                    │ Metrics Service     │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │    PostgreSQL       │
                    │                     │
                    │ Services            │
                    │ Dependencies        │
                    │ Scenarios            │
                    │ Events              │
                    │ Results             │
                    └─────────────────────┘
```

## 4. Frontend Architecture

``` text
src/
├── assets/
├── components/
│   ├── cinematic/
│   ├── graph/
│   ├── simulation/
│   ├── metrics/
│   ├── timeline/
│   └── common/
├── hooks/
│   ├── useSimulation.ts
│   ├── useGraph.ts
│   └── useVideoScrub.ts
├── pages/
│   └── App.tsx
├── services/
│   └── api.ts
├── types/
│   ├── graph.ts
│   ├── simulation.ts
│   └── scenario.ts
├── utils/
└── main.tsx
```

## 5. Backend Architecture

``` text
server/
├── src/
│   ├── config/
│   ├── controllers/
│   ├── routes/
│   ├── services/
│   │   ├── graphService.ts
│   │   ├── simulationService.ts
│   │   ├── metricsService.ts
│   │   └── scenarioService.ts
│   ├── simulation/
│   │   ├── engine.ts
│   │   ├── propagation.ts
│   │   ├── recovery.ts
│   │   └── metrics.ts
│   ├── models/
│   ├── middleware/
│   ├── utils/
│   └── server.ts
└── tests/
```

## 6. Core Simulation Model

The city is represented as a directed graph:

``` text
G = (V, E)
```

Where: - `V` = infrastructure services. - `E` = dependency
relationships.

Each service has a state:

``` text
HEALTHY
DEGRADED
FAILED
RECOVERING
RECOVERED
```

Each simulation tick evaluates: 1. Current service state. 2. Dependency
states. 3. Failure rules. 4. Recovery rules. 5. State transitions. 6.
Metrics. 7. Event creation.

## 7. Dependency Model

Example:

``` text
Power Grid
    ↓
Hospital

Power Grid
    ↓
Water Supply

Transport
    ↓
Emergency Services
```

Dependencies must have a defined direction.

Example:

``` text
A → B
```

means B depends on A.

## 8. Simulation Engine

The engine should be deterministic.

Input:

``` text
Graph
Initial states
Disruptions
Simulation configuration
```

Output:

``` text
Simulation events
State snapshots
Metrics
Final state
```

Pseudo-flow:

``` text
initialize()
    ↓
apply initial disruptions
    ↓
for each simulation tick:
    evaluate dependencies
    ↓
    calculate state transitions
    ↓
    record events
    ↓
    calculate metrics
    ↓
apply recovery actions
    ↓
continue until stable/end time
    ↓
return result
```

## 9. API Design

### Scenarios

``` text
GET    /api/scenarios
GET    /api/scenarios/:id
POST   /api/scenarios
PUT    /api/scenarios/:id
DELETE /api/scenarios/:id
```

### Infrastructure

``` text
GET /api/services
GET /api/services/:id
GET /api/dependencies
```

### Simulation

``` text
POST /api/simulations
GET  /api/simulations/:id
POST /api/simulations/:id/recovery
POST /api/simulations/:id/reset
```

### Results

``` text
GET /api/simulations/:id/events
GET /api/simulations/:id/metrics
GET /api/simulations/:id/timeline
```

## 10. API Response Principle

Responses should be predictable:

``` json
{
  "success": true,
  "data": {},
  "error": null
}
```

Errors:

``` json
{
  "success": false,
  "data": null,
  "error": {
    "code": "SCENARIO_NOT_FOUND",
    "message": "Scenario was not found."
  }
}
```

## 11. Graph Rendering Strategy

The graph should use: - Node status visualization. - Directed edges. -
Animated propagation. - Hover details. - Click-to-inspect. - Zoom and
pan. - Fit-to-screen. - Clear selected state.

For the MVP, avoid excessive visual effects that reduce graph
readability.

## 12. Cinematic Layer

The cinematic landing section is independent from the simulation engine.

It should: - Use a full-screen visual/video. - Use scroll position to
drive progression. - Transition into the simulator. - Remain
lightweight. - Respect prefers-reduced-motion.

The exact cinematic implementation can use the supplied WebCodecs/mp4box
approach when required by the UI specification.

## 13. State Management

Keep state separated:

``` text
UI State
Simulation State
Graph State
Scenario State
```

Do not put the entire application state into one large global object.

## 14. Security

For MVP: - Validate all API inputs. - Never trust client-side simulation
results. - Sanitize user-created scenario names. - Use parameterized
database queries. - Store secrets only in environment variables. - Add
rate limiting before public deployment.

## 15. Deployment

Recommended:

``` text
Frontend → Vercel
Backend  → Railway / Render
Database → Railway PostgreSQL / Supabase
```

Exact provider can be selected during deployment phase.

## 16. Architecture Rule

Architecture changes must be documented here before implementation if
they materially affect folder structure, technology, data flow, or
simulation behavior.
