# 01 — High-Level System Architecture

The **Urban Infrastructure Cascade Simulator** implements a high-resilience, multi-tier architecture enabling interactive modeling of municipal network failures and recovery cascades.

```mermaid
flowchart TB
    subgraph Clients["Presentation & Client Layer"]
        subgraph MobileApp["Flutter Mobile App (iOS / Android)"]
            MobileUI["Mobile UI / Screens<br/>(Cinematic Hero, Graph Canvas, Controls)"]
            MobileState["State Management<br/>(SimulationController & ThemeController)"]
            MobileOffline["Edge Deterministic Engine<br/>(Offline Simulation Fallback)"]
            MobileHTTP["Mobile HTTP Client<br/>(ApiService with Auto-Health Check)"]
        end

        subgraph WebApp["React 19 Web Dashboard (Vite + TS)"]
            WebUI["Web UI Components<br/>(Hero, Workspace, Controls, Timeline)"]
            WebGraph["@xyflow/react Graph Canvas<br/>(Pan / Zoom / Interactive Nodes)"]
            WebSim["Client-Side Simulation Runner<br/>(Fast In-Browser Execution)"]
            WebHTTP["Axios / Fetch API Client<br/>(REST Integration Layer)"]
        end
    end

    subgraph API["Backend Application Layer (Node.js + Express + TypeScript)"]
        Router["Express API Router<br/>(/api/services, /dependencies, /scenarios, /simulations)"]
        Middleware["Middleware Pipeline<br/>(CORS, JSON Parser, Error Handler)"]
        
        subgraph Services["Core Application Services"]
            GraphSvc["GraphService<br/>(Nodes & Directed Edges)"]
            ScenarioSvc["ScenarioService<br/>(Disruption Management & Seed Config)"]
            SimSvc["SimulationService<br/>(Simulation Lifecycle Orchestrator)"]
            MetricsSvc["MetricsService<br/>(Analytics & Cascade Depth)"]
        end

        subgraph SimEngine["Deterministic Simulation Engine"]
            PropEngine["Propagation Engine<br/>(Stress Calculation & Threshold Trigger)"]
            RecEngine["Recovery Engine<br/>(Tick Progression & De-escalation)"]
            MetricsCalc["Metrics Calculator<br/>(Shortest-path BFS Depth & Impact %)"]
        end
    end

    subgraph Persistence["Persistence & Storage Layer"]
        DBPool["PostgreSQL Connection Pool<br/>(pg.Pool with IPv4 & SSL Fallback)"]
        PostgresDB[("PostgreSQL Database<br/>(Services, Dependencies, Scenarios,<br/>Simulations, Events, Metrics)")]
        MemStore[("In-Memory Demo Store<br/>(Zero-Config Local Fallback)")]
    end

    %% Client to Backend connections
    MobileHTTP -->|"REST / JSON (HTTP/HTTPS)"| Router
    WebHTTP -->|"REST / JSON (HTTP/HTTPS)"| Router

    %% Internal Mobile & Web flows
    MobileUI <--> MobileState
    MobileState <--> MobileOffline
    MobileState <--> MobileHTTP

    WebUI <--> WebGraph
    WebUI <--> WebSim
    WebUI <--> WebHTTP

    %% Backend internal flows
    Router --> Middleware --> Services
    GraphSvc --> SimEngine
    ScenarioSvc --> SimEngine
    SimSvc --> SimEngine

    %% Backend to Database flows
    Services --> DBPool
    DBPool --> PostgresDB
    Services -.->|"Fallback if DB unreachable"| MemStore
```

---

## Architectural Highlights
1. **Multi-Platform Consistency**: Mobile (Flutter) and Web (React 19) consume the exact same REST API format and share the same design language and color tokens.
2. **Dual-Tier Simulation Engine**: The deterministic cascade algorithm runs identically in the backend cloud service (TypeScript) or locally on the mobile/web client (Dart/TypeScript) for offline resilience.
3. **Graceful Fallback Strategy**:
   - Backend auto-detects PostgreSQL connectivity. If unreachable, it falls back to an in-memory repository without breaking API calls.
   - Mobile and Web clients auto-detect backend availability. If offline, they switch seamlessly to local deterministic simulation.
