# Urban Infrastructure Cascade Simulator

An interactive web application that models interdependent urban services as a
dynamic graph and simulates how a failure in one service (e.g. a power grid
outage) cascades into others — then lets you apply recovery actions and
measure the impact.

**Problem Statement:** S-03 — Urban Infrastructure Cascade Simulator
**Category:** Smart Cities & Urban Infrastructure

---

## Table of Contents

- [Urban Infrastructure Cascade Simulator](#urban-infrastructure-cascade-simulator)
  - [Table of Contents](#table-of-contents)
  - [1. Problem Statement \& Solution Overview](#1-problem-statement--solution-overview)
    - [The Problem](#the-problem)
    - [The Solution](#the-solution)
  - [2. System Architecture / Workflow](#2-system-architecture--workflow)
    - [End-to-End User Workflow](#end-to-end-user-workflow)
  - [3. Core Technical Mechanism](#3-core-technical-mechanism)
    - [Dependency Graph](#dependency-graph)
    - [Failure Propagation](#failure-propagation)
    - [Recovery](#recovery)
    - [Stabilization \& Determinism](#stabilization--determinism)
    - [Metrics Calculation](#metrics-calculation)
  - [4. Technology Stack](#4-technology-stack)
    - [Frontend](#frontend)
    - [Backend](#backend)
    - [Database](#database)
    - [Tooling](#tooling)
  - [5. Setup \& Installation](#5-setup--installation)
    - [Prerequisites](#prerequisites)
    - [1. Clone the repository](#1-clone-the-repository)
    - [2. Backend setup](#2-backend-setup)
    - [3. Frontend setup](#3-frontend-setup)
    - [4. Environment variables](#4-environment-variables)
  - [6. Usage Instructions](#6-usage-instructions)
  - [7. Validation / Experiments / Results](#7-validation--experiments--results)
    - [Automated Tests](#automated-tests)
    - [Manual Validation — Reference Scenario](#manual-validation--reference-scenario)
    - [Known-good Environments](#known-good-environments)
  - [8. Limitations \& Future Scope](#8-limitations--future-scope)
    - [Current Limitations](#current-limitations)
    - [Planned Future Work (Phase 14 — see `phases.md`)](#planned-future-work-phase-14--see-phasesmd)
  - [9. Team Members](#9-team-members)
  - [10. AI Assistance Disclosure](#10-ai-assistance-disclosure)
  - [11. Project Documentation Index](#11-project-documentation-index)
  - [12. License](#12-license)

---

## 1. Problem Statement & Solution Overview

### The Problem

Urban services — power, water, hospitals, transport, communication,
emergency response — are deeply interconnected. A failure in one digital or
operational service can silently propagate into others, creating cascading
failures that are hard to detect with isolated, per-service monitoring
systems. City planners and infrastructure analysts currently lack an easy
way to **visualize these dependencies** and **simulate "what if" failure
scenarios** before they happen in the real world.

### The Solution

The Urban Infrastructure Cascade Simulator represents a city's critical
services (Power Grid, Water Supply, Hospital, Emergency Services, Public
Transport, Residential Areas, Communication Network, Waste Management,
Industrial Services) as a **dependency graph**, and provides:

- A deterministic **failure-propagation engine** that spreads stress from a
  failed/degraded service to everything that depends on it.
- Support for **multiple simultaneous disruptions**.
- A **recovery engine** that reverses the cascade once a root-cause service
  is restored.
- Live **metrics** (cascade depth, affected services, recovery time, system
  impact %) and an **event timeline**.
- **Reproducible scenarios** — the same scenario + configuration always
  produces the same simulation result.
- A cinematic landing experience that introduces the problem before handing
  the user into the interactive simulator.

The product deliberately does **not** connect to real infrastructure,
control real devices, or claim to predict real-world disasters — it is a
decision-support / educational simulation tool.

---

## 2. System Architecture / Workflow

The application follows a three-layer architecture:

```text
┌─────────────────────────────┐
│        React Frontend       │
│  Cinematic Landing          │
│  Infrastructure Graph (RF)  │
│  Simulation Controls        │
│  Timeline + Metrics         │
│  Scenario Manager           │
└──────────────┬───────────────┘
               │ REST (JSON)
               ▼
┌─────────────────────────────┐
│        Express API          │
│  Graph Service               │
│  Scenario Service            │
│  Simulation Service          │
│  Metrics Service             │
│  Validation + Error Handling │
└──────────────┬───────────────┘
               │
               ▼
┌─────────────────────────────┐
│         PostgreSQL           │
│  Services / Dependencies     │
│  Scenarios / Disruptions     │
│  Simulation Runs / Events    │
│  Snapshots / Metrics         │
└─────────────────────────────┘
```

The frontend can also run the simulation engine **entirely client-side**
(deterministic, no network needed) using the same core logic mirrored in
`frontend/src/simulation/`, so the demo still works if the backend/database
is unreachable (see connection-state badge in the UI: PostgreSQL Connected /
In-Memory Fallback / Offline Fallback).

### End-to-End User Workflow

```text
Open App
   ↓
Cinematic intro (problem framing)
   ↓
Enter Simulator
   ↓
Select or create a scenario
   ↓
View infrastructure dependency graph
   ↓
Select one or more services to disrupt
   ↓
Run simulation → cascade propagates tick-by-tick
   ↓
Inspect timeline + live metrics
   ↓
Apply recovery actions
   ↓
System stabilizes → final metrics shown
   ↓
Save / replay scenario for reproducibility
```

Full component/service breakdown is documented in [`architecture.md`](./architecture.md).

---

## 3. Core Technical Mechanism

### Dependency Graph

Each service is a node; each dependency is a directed, weighted edge
(`dependencyStrength`). The graph is seeded deterministically
(`frontend/src/data/seedInfrastructure.ts`, `backend/src/data/seedInfrastructure.ts`)
and rendered with **React Flow**.

### Failure Propagation

Implemented in `frontend/src/simulation/propagation.ts` and mirrored in
`backend/src/simulation/propagation.ts`. Each simulation **tick**:

1. Applies any configured disruptions for that tick (setting initial
   `severity`).
2. For every other service, sums **upstream stress**: a `FAILED` upstream
   dependency contributes its full `dependencyStrength`; a `DEGRADED`
   upstream contributes `0.5 × dependencyStrength`.
3. Thresholds decide the next state:
   - `stress ≥ 1.0` → `FAILED`
   - `stress ≥ 0.5` → `DEGRADED`
   - otherwise → `HEALTHY` (or recovering, see below)
4. State transitions are recorded as timeline events (`FAILED`,
   `DEGRADED`, `PROPAGATION`, `RECOVERY`, etc.).

### Recovery

Implemented in `frontend/src/simulation/recovery.ts`. When a user triggers
recovery on a service, it moves `RECOVERING → RECOVERED → HEALTHY`, and
dependents are re-evaluated on each tick so the cascade can unwind. Recovery
time is measured from disruption start to full stabilization.

### Stabilization & Determinism

A simulation is considered **stable** after 3 consecutive ticks with no
state changes, or when the configured duration limit is reached. Because
propagation is a pure function of graph state + disruption configuration
(no randomness), the **same scenario always reproduces the same result** —
this is verified by the unit tests described in [Section 7](#7-validation--experiments--results).

### Metrics Calculation

`frontend/src/simulation/metrics.ts` / `backend/src/simulation/metrics.ts`
compute:

| Metric | Definition |
|---|---|
| Affected Services | Count of services that left `HEALTHY` at any point |
| Cascade Depth | Longest chain of propagation from the original disruption |
| Recovery Time | Simulation ticks/time from disruption to full stabilization |
| System Impact % | Weighted share of the network affected, by criticality |

---

## 4. Technology Stack

### Frontend
- FlutterDart
- http
- Web Sokets

### Backend
- Node.js
- Express
- TypeScript
- REST API with request validation and centralized error handling
- Vitest (route/integration tests)

### Database
- PostgreSQL (with a deterministic in-memory fallback for local/offline use)

### Tooling
- ESLint + Prettier
- Git / GitHub
- dotenv for environment configuration

---

## 5. Setup & Installation

### Prerequisites
- Node.js 18+ and npm
- (Optional, for persistence) A PostgreSQL database — e.g. local Postgres or
  a hosted instance such as Supabase

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd Urban_Infrastructure_Cascade_Simulator
```

### 2. Backend setup

```bash
cd backend
npm install
cp .env.example .env   # then fill in DATABASE_URL, PORT, CORS_ORIGIN
```

Run migrations and seed the deterministic demo network:

```bash
flutter create . --platform=android
flutter pub get
```

> If `DATABASE_URL` is not reachable, the backend still starts and serves
> the deterministic in-memory graph/scenario data as a fallback.

### 3. Frontend setup

```bash
cd frontend
flutter create . --platform=android
cp .env.example .env   # set VITE_API_URL to your backend URL
flutter run
```

The app will be available at `http://localhost:5173` by default.

### 4. Environment variables

`backend/.env`
```env
DATABASE_URL=your_database_url
PORT=5000
CORS_ORIGIN=http://localhost:5173
```

`frontend/.env`
```env
VITE_API_URL=http://localhost:5000
```

Never commit real `.env` files or secrets — only `.env.example` is tracked.

---

## 6. Usage Instructions

1. **Open the app** — you'll land on the cinematic introduction; scroll or
   click **Run Simulation** to enter the simulator.
2. **Pick a scenario** — use the built-in "Power Grid Failure" demo
   scenario, or create/save your own from the Scenario Manager panel.
3. **Explore the graph** — pan/zoom the infrastructure graph, click a node
   to see its details, dependencies, and dependents.
4. **Configure a disruption** — select one or more services to fail; set
   severity/timing if supported by the scenario.
5. **Run the simulation** — watch the graph animate the cascade in real
   time; the timeline logs every failure/propagation event.
6. **Read the metrics** — cascade depth, affected services, recovery time,
   and system impact % update live in the metric cards.
7. **Apply recovery** — select affected services and trigger recovery to
   watch the cascade unwind and the system stabilize.
8. **Reset or replay** — reset to the initial state at any time, or re-run
   the same saved scenario to confirm it reproduces identical results.
9. **Toggle theme** — switch between light/dark mode from the nav bar.

---

## 7. Validation / Experiments / Results

### Automated Tests

The core simulation logic and key UI flows are covered by Vitest test
suites:

**Frontend (`frontend/src/**`)**
- `simulation/propagation.test.ts` — verifies dependency-stress
  accumulation and `HEALTHY → DEGRADED → FAILED` threshold transitions.
- `simulation/recovery.test.ts` — verifies `RECOVERING → RECOVERED →
  HEALTHY` transitions and dependent de-escalation.
- `simulation/metrics.test.ts` — verifies cascade depth, affected-service
  count, and recovery-time calculations against known graphs.
- `components/simulation/SimulationControls.test.tsx`,
  `ScenarioManager.test.tsx`, `SimulationTimeline.test.tsx` — UI/component
  behavior, including friendly-name translation and API mocking.

**Backend (`backend/src/**`)**
- `routes/scenarios.test.ts` — request validation and scenario CRUD
  contract tests.

Run all tests:

```bash
# frontend
cd frontend && flutter test

# backend
cd backend && npm run test
```

### Manual Validation — Reference Scenario

**Scenario:** Power Grid Failure (deterministic seed)

| Step | Expected Result |
|---|---|
| Power Grid fails at T+0 | Node turns `FAILED` |
| Hospital, Water, Transport (direct dependents) | Turn `DEGRADED` or `FAILED` depending on `dependencyStrength` |
| Emergency Services (second-order dependent) | Becomes impacted via cascade |
| Metrics panel | Cascade depth ≥ 2, affected services ≥ 4 |
| Recovery triggered on Power Grid | Dependents transition back through `RECOVERING → HEALTHY` |
| Re-running the same scenario | Produces identical cascade depth, affected services, and recovery time (determinism check) |

This scenario is used as the standard demo flow (see `phases.md`, Phase 13)
and as the basis for the automated propagation/recovery/metrics tests
above.

### Known-good Environments

Manually verified on:
- Chrome, desktop, light and dark theme
- Responsive layout down to mobile viewport widths (graph → metrics →
  controls → timeline reflow)
- Backend deployed with PostgreSQL (Supabase) and with in-memory fallback

---

## 8. Limitations & Future Scope

### Current Limitations

- No user authentication — scenarios are not scoped to individual users.
- Failure propagation uses a single stress-accumulation formula; it does
  not model more complex real-world dynamics (partial capacity, load
  balancing, time-of-day effects).
- No live/auto-play mode yet — the timeline is inspected manually rather
  than auto-advanced.
- No export/sharing of results outside the app (no PDF/CSV report).
- Graph topology is limited to the seeded demo network; there is no UI yet
  to build a custom city graph.
- Does not connect to, monitor, or control any real infrastructure — by
  design, this is a simulation/decision-support tool only.

### Planned Future Work (Phase 14 — see `phases.md`)

- Export/share simulation reports (PDF/PNG/CSV).
- Scenario comparison (run two scenarios side-by-side).
- Live/auto-play simulation mode with speed control.
- User authentication and per-user saved scenarios.
- Alerts & notifications panel for critical-service failures.
- Custom graph builder (add/edit services and dependencies).
- Onboarding walkthrough and further theme polish.
- Mobile simulator interaction audit.
- AI-generated plain-English impact summaries.
- PWA packaging / installable "Download App" experience.

---

## 9. Team Members

| Name | Role |
|---|---|
| Mohit | Android Developer & full stack|

*(Update names/roles above to match final team credits before submission.)*

---

## 10. AI Assistance Disclosure

Parts of this project were built with AI assistance (Claude, Anthropic):

- Scaffolding of the frontend (Vite/React/TypeScript/Tailwind) and backend
  (Express/TypeScript) project structure.
- Drafting of initial documentation (`PRD.md`, `architecture.md`,
  `database.md`, `design.md`, `phases.md`, `rules.md`, `memory.md`) which
  was then reviewed and iterated on by the team.
- Implementation assistance for the cascade propagation engine, recovery
  engine, metrics calculations, and simulation timeline.
- UI component implementation (cinematic landing, infrastructure graph,
  simulation controls, scenario manager) based on the team's design
  direction.
- Debugging assistance for deployment issues (CORS, database SSL/DNS
  configuration) and simulation logic bugs.
- Test scaffolding for Vitest unit/integration/UI test suites.

All AI-assisted code and documentation was reviewed, tested, and adjusted
by the team before inclusion. Architectural decisions, feature scope, and
final review remained with the team throughout.

---

## 11. Project Documentation Index

| File | Purpose |
|---|---|
| `README.md` | Project overview, setup, usage, validation (this file) |
| `PRD.md` | Product requirements and scope |
| `architecture.md` | Application architecture and technical structure |
| `database.md` | Database schema and data model |
| `design.md` | UI, typography, colors and visual rules |
| `phases.md` | Development roadmap (Phases 0–14) |
| `rules.md` | Development constraints |
| `memory.md` | Current project state, decisions, and change log |

---

## 12. License

Add the final project license before public release.
