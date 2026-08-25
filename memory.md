# Project Memory --- Urban Infrastructure Cascade Simulator

## Project Status

**Status:** Phase 12 complete\
**Current Phase:** Complete\
**Next Phase:** None

## Project Identity

**Name:** Urban Infrastructure Cascade Simulator\
**Problem Statement:** S-03\
**Category:** Smart Cities & Urban Infrastructure

## Core Problem

Urban services are interconnected. A failure in one service can
propagate into other services.

The system must represent these dependencies as a dynamic graph and
simulate disruption propagation.

## Confirmed Requirements

-   Dynamic graph.
-   Time-dependent state.
-   Failure simulation.
-   Recovery simulation.
-   Multiple simultaneous disruptions.
-   Cascade depth measurement.
-   Affected service measurement.
-   Recovery time measurement.
-   Reproducible scenarios.

## Product Direction

The project will use a premium cinematic introduction followed by an
interactive infrastructure simulator.

The cinematic layer is intended to create a strong first impression.

The simulator is the functional core.

## Current Technology Direction

### Frontend

-   Vite
-   React 18
-   TypeScript
-   Tailwind CSS 3
-   lucide-react

### Backend

-   Node.js
-   Express
-   TypeScript

### Database

-   PostgreSQL

## Current UI Direction

### Cinematic

-   Full-screen visual/video.
-   Scroll-driven transition.
-   Minimal navigation.
-   Large typography.
-   Navy/white visual system.

### Simulator

-   Infrastructure graph.
-   Simulation controls.
-   Metrics.
-   Timeline.
-   Recovery controls.
-   Scenario management.

## Initial Demo Scenario

Power Grid Failure.

Expected demonstration: 1. Power fails. 2. Dependent services
degrade/fail. 3. Cascade propagates. 4. Metrics update. 5. Recovery
begins. 6. Services recover. 7. Final recovery time is shown. 8.
Scenario can be replayed.

## Documentation State

  File              Status
  ----------------- ----------
  PRD.md            Complete
  architecture.md   Complete
  database.md       Complete
  design.md         Complete
  phases.md         Complete
  rules.md          Complete
  memory.md         Active
  README.md         Complete

## Decisions

### Decision 001 --- Web-first implementation

The core MVP will be built as a web application without physical
infrastructure or hardware dependencies.

### Decision 002 --- Deterministic simulation

Scenarios should be reproducible using a stored seed/configuration.

### Decision 003 --- Cinematic + functional hybrid

The project will not be only a landing page. The cinematic layer
introduces the problem and the interactive simulator demonstrates the
actual solution.

### Decision 004 --- PostgreSQL

Use PostgreSQL for structured infrastructure, scenario, event and metric
data.

### Decision 005 --- React Flow for graph rendering

Use `@xyflow/react` for the MVP infrastructure graph (zoom, pan, nodes, directed edges).

## Pending Decisions

-   Exact graph library: React Flow vs custom SVG/canvas. **Resolved:** React Flow (`@xyflow/react`).
-   Exact backend hosting provider.
-   Exact database hosting provider.
-   Whether authentication is included in MVP.
-   Exact simulation propagation formula. **Resolved:** stress-based propagation (upstream FAILED = +strength, DEGRADED = +0.5×strength; ≥0.5 → DEGRADED, ≥1.0 → FAILED).
-   Exact stabilization condition. **Resolved:** simulation ends after 3 consecutive ticks with no state changes, or at duration limit.

## Change Log

### 2026-08-24 (Phase 6)

- Built metric cards row (affected services, cascade depth, recovery time, system impact).
- Added horizontal timeline with Failure → Propagation → Recovery → Stable phases.
- Added simulation progress bar, live metric updates, and click-to-inspect timeline events.

### 2026-08-24 (Phase 7)

- Built Express REST API with health, service, dependency, scenario, simulation, recovery, reset, event, metric, and timeline endpoints.
- Added request validation, consistent API responses, and centralized error handling.
- Added PostgreSQL connectivity configuration with deterministic in-memory storage as the Phase 8 persistence fallback.
- Verified the API through a health, graph, scenario, and simulation smoke test.

### 2026-08-24 (Phase 5)

- Implemented recovery engine with RECOVERING → RECOVERED → HEALTHY transitions.
- Added recovery action UI, dependent de-escalation, and recovery time measurement.
- Recovery propagates when upstream services restore; timeline shows recovery events.

### 2026-08-24 (Phase 4)

- Implemented deterministic simulation engine (ticks, disruptions, dependency propagation).
- Added multiple simultaneous disruption support and power-grid demo scenario.
- Wired run/reset controls, animated edge propagation, timeline, and basic impact metrics.
- Simulation logic lives in `frontend/src/simulation/` independent from UI components.

### 2026-08-24 (Phase 3)

- Built interactive infrastructure graph with React Flow.
- Added status-aware service nodes, directed dependency edges, zoom/pan/fit controls.
- Seeded deterministic city network (Power Grid, Hospital, Water, Transport, etc.).
- Added node selection with service details panel (dependencies and dependents).

### 2026-08-24 (implementation)

- Initialized frontend (`frontend/`) with Vite, React 19, TypeScript, Tailwind CSS 3, lucide-react.
- Initialized backend (`backend/`) with Express, TypeScript, CORS, health API.
- Built cinematic landing page with scroll-driven progression and mobile navigation.
- Added simulator placeholder section for Phase 3+ work.

### 2026-08-24 (planning)

- Selected S-03 as project problem statement.
-   Defined interactive simulator direction.
-   Created initial PRD.
-   Created architecture plan.
-   Created database design.
-   Created visual design system.
-   Created development phases.
-   Created project rules.
-   Created project memory.

## Important Rule

Update this file whenever: - A phase is completed. - A major
architecture decision changes. - A database decision changes. - A
feature is added/removed. - A major bug is fixed. - The current file
being worked on changes.

## Current Work

**Current task:** Project Completed.

**Completed:**
- Phases 0–5: Full failure + recovery simulation
- Phase 6: Metric cards, horizontal timeline, simulation progress, live analytics
- Phase 7: Validated Express API with in-memory demo storage and PostgreSQL connection configuration
- Phase 8-9: Database integration and Scenario CRUD/loading UI
- Phase 10: Responsive layout, layout ordering, a11y, API resilience, connection state indicator, and timeline names mapping
- Phase 11: Set up Vitest test suites (unit, integration, and UI component testing) with all tests passing successfully
- Phase 12: Configured production migration/seeding script tasks and created frontend/backend environment parameter templates

**Next task:** None.

### 2026-08-24 (Phase 8 - in progress)

- Added a versioned initial PostgreSQL migration for services, dependencies,
  scenarios, disruptions, simulations, events, snapshots, and metrics.
- Added idempotent deterministic seed data for the city infrastructure graph
  and City Power Failure demo scenario.
- Added `npm run migrate` and `npm run seed` backend commands.
- Added PostgreSQL-backed graph and scenario reads/writes when `DATABASE_URL`
  is reachable; the existing deterministic in-memory mode remains the local
  fallback.
- Persisted each completed simulation's run record, events, final snapshot,
  and metrics to PostgreSQL.

### 2026-08-24 (Phase 8 complete)

- Added restart-safe retrieval for PostgreSQL-persisted simulation records,
  events, metrics, and final states.
- Applied the initial migration and deterministic seed data to Supabase.
- Verified PostgreSQL-backed graph and scenario APIs, simulation persistence,
  and persisted simulation retrieval after restarting the API.

### 2026-08-24 (Phase 9 complete)

- Added a saved-scenarios panel backed by the REST API.
- Users can create, load, edit, duplicate, and delete saved scenarios.
- The simulator loads the live infrastructure graph when the API is available,
  ensuring saved disruptions use the same service IDs as PostgreSQL.
- Saved scenarios load into the existing simulation controls and can then be
  run through the normal deterministic simulation flow.

### 2026-08-24 (Phase 10 complete)

- Refactored grid layout in `SimulatorWorkspace.tsx` with responsive flex/grid ordering (`Graph` -> `Metrics` -> `Controls` -> `Timeline` on mobile screens).
- Added health-checking capability and a connection state badge indicating active storage modes (PostgreSQL Connected, In-Memory Fallback, Offline Fallback).
- Mapped service IDs to human-readable names and translated event types in the timeline display.
- Enhanced accessibility on controls with ARIA states (`aria-pressed`, `aria-label`) and prominent keyboard focus indicators.
- Hardened the REST request wrapper to catch network drops and return a structured error response gracefully.

### 2026-08-24 (Phase 11 complete)

- Configured Vitest as the testing runner in both the frontend and backend.
- Wrote unit tests for propagation (`propagation.test.ts`), recovery (`recovery.test.ts`), and metrics calculation (`metrics.test.ts`).
- Wrote component test suites checking UI logic for `SimulationControls`, `ScenarioManager`, and `SimulationTimeline` (mocking API endpoints, testing friendly name translation).
- Wrote integration tests for backend router validation rules (`scenarios.test.ts`).
- Verified that all unit, integration, and UI test files build and run with 100% success.

### 2026-08-24 (Theme Toggle complete)

- Added a stateful light/dark mode theme toggle.
- Set up Tailwind `class` based dark mode support.
- Configured style variables for graph canvas backgrounds, and adapted all workspace panels, controls, progress indicators, nodes, and buttons for light/dark theme responsiveness.
- Ensured all tests compile and execute cleanly in both environments.

### 2026-08-24 (Phase 12 complete)

- Added production database migrate and seed scripts inside `backend/package.json` that execute compiled JS output.
- Created `backend/.env.example` defining database URLs and CORS locks.
- Created `frontend/.env.example` defining API variables.
- Moved `typescript` and typescript type definitions for Node, Express, pg, and CORS into production `"dependencies"` inside `backend/package.json`. This forces Render/Railway build containers to install them and compile correctly under `NODE_ENV=production`.
- Force Node.js DNS resolution order to `ipv4first` in database migrate (`migrate.ts`), seed (`seed.ts`), and web API (`server.ts`) entrypoints to bypass Render's IPv6 networking (`ENETUNREACH`) blocks on outgoing requests.
- Configure `ssl: { rejectUnauthorized: false }` in `backend/src/db/pool.ts` database connection pool configuration when SSL is required. This prevents node-postgres from rejecting self-signed or internal CA certificate chains returned by cloud database managers like Supabase.
- Bind backend server host from `127.0.0.1` to `0.0.0.0` in [`backend/src/server.ts`](file:///c:/Users/dexte/Downloads/S03_Urban_Infrastructure_Cascade_Simulator_MD_Files/backend/src/server.ts) to allow incoming traffic routing and port binding on cloud services (Render, Railway).
- Sanitize `CORS_ORIGIN` variables to strip trailing slashes in [`backend/src/server.ts`](file:///c:/Users/dexte/Downloads/S03_Urban_Infrastructure_Cascade_Simulator_MD_Files/backend/src/server.ts), resolving CORS preflight check rejects.
- Fix recovery simulation premature termination bug in [`frontend/src/simulation/recovery.ts`](file:///c:/Users/dexte/Downloads/S03_Urban_Infrastructure_Cascade_Simulator_MD_Files/frontend/src/simulation/recovery.ts) by setting `changed = true` on any active tick progress. This ensures the engine doesn't falsely assume stability and break the loop before the service finishes recovering.
- Verified that all compilation builds pass and are ready for hosting pipelines.
