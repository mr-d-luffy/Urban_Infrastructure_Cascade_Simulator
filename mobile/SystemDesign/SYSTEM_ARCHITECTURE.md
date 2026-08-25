# Urban Infrastructure Cascade Simulator — Complete System Design & Architecture

This document provides the authoritative technical specification and architectural blueprint for the **Urban Infrastructure Cascade Simulator**. It details the multi-tier topology, mobile and web presentation layers, deterministic simulation engine, backend REST API, database schema, mathematical models, and lifecycle sequence flows.

---

## Table of Contents
1. [High-Level System Architecture](#1-high-level-system-architecture)
2. [Presentation Layer (Mobile & Web)](#2-presentation-layer-mobile--web)
3. [Backend API & Simulation Engine Pipeline](#3-backend-api--simulation-engine-pipeline)
4. [Mathematical Model & Cascade Propagation Formulas](#4-mathematical-model--cascade-propagation-formulas)
5. [Database Entity-Relationship Model (ERD)](#5-database-entity-relationship-model-erd)
6. [Service State Machine & Lifecycle Transitions](#6-service-state-machine--lifecycle-transitions)
7. [End-to-End Simulation Execution Sequence](#7-end-to-end-simulation-execution-sequence)
8. [Cross-Cutting Architectural Principles](#8-cross-cutting-architectural-principles)

---

## 1. High-Level System Architecture

The simulator uses a three-tier architecture with multi-platform client support (Flutter Mobile + React Web), a high-performance Express REST API, a dual-mode deterministic simulation engine (capable of running in the cloud or directly on edge devices with zero latency offline fallback), and a persistent PostgreSQL database backed by an in-memory fallback store.

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

## 2. Presentation Layer (Mobile & Web)

The user interfaces on both Mobile and Web share the same strict design tokens, color palette, dark/light themes, and interactive capabilities while being optimized for their respective interaction patterns.

### Client Subsystem Comparison

```mermaid
flowchart LR
    subgraph MobileArchitecture["Flutter Mobile App Architecture (lib/)"]
        direction TB
        M_View["Widgets & Screens<br/>• HomeScreen<br/>• InteractiveViewer Graph Canvas<br/>• MetricCards & Progress Bar<br/>• Controls & Timeline Stream"]
        M_Ctrl["ChangeNotifier State Controllers<br/>• SimulationController<br/>• ThemeController"]
        M_Eng["Edge Simulation Engine (Dart)<br/>• PropagationEngine<br/>• RecoveryEngine<br/>• MetricsCalculator"]
        M_API["API Client (ApiService)<br/>• Dynamic Base URL Config<br/>• Real-time Backend Health Polling"]

        M_View <--> M_Ctrl
        M_Ctrl <--> M_Eng
        M_Ctrl <--> M_API
    end

    subgraph WebArchitecture["React Web App Architecture (frontend/src/)"]
        direction TB
        W_View["React Components<br/>• Cinematic Landing Hero<br/>• SimulatorWorkspace<br/>• @xyflow/react Graph Canvas<br/>• ScenarioManager & Timeline"]
        W_Hook["Custom React Hooks<br/>• useSimulation<br/>• useGraph<br/>• useTheme"]
        W_Eng["Client Simulation Engine (TS)<br/>• engine.ts & propagation.ts<br/>• recovery.ts & metrics.ts"]
        W_API["API Client (api.ts)<br/>• Structured REST Client<br/>• Fallback State Handling"]

        W_View <--> W_Hook
        W_Hook <--> W_Eng
        W_Hook <--> W_API
    end
```

---

## 3. Backend API & Simulation Engine Pipeline

The Express backend provides clean REST endpoints with centralized error handling, request validation, deterministic execution, and database persistence.

```mermaid
flowchart TD
    subgraph API_Gateway["Express API Layer (/api)"]
        HealthRoute["GET /health<br/>(Returns status & active storage engine)"]
        GraphRoute["GET /services<br/>GET /dependencies<br/>(Network topology)"]
        ScenarioRoute["GET, POST, PUT, DELETE /scenarios<br/>(Scenario CRUD & Disruptions)"]
        SimulationRoute["POST /simulations/run<br/>POST /simulations/step<br/>POST /simulations/recover"]
    end

    subgraph Simulation_Pipeline["Deterministic Simulation Pipeline"]
        Init["1. Initialize Runtime States & Upstream Graph Map"]
        ApplyDisrupt["2. Apply Initial Disruptions (T = 0)"]
        TickLoop["3. Tick Evaluation Loop (T = T + tickSeconds)"]
        CalcStress["4. Compute Cumulative Upstream Stress"]
        StateTrans["5. Resolve State Transitions & Log Events"]
        EvalRecovery["6. Process Recovery Progress & De-escalate Dependents"]
        CheckStable["7. Check Stabilization Criteria (3 consecutive stable ticks)"]
        FinalMetrics["8. Calculate Cascade Depth & System Impact %"]

        Init --> ApplyDisrupt --> TickLoop
        TickLoop --> CalcStress --> StateTrans --> EvalRecovery --> CheckStable
        CheckStable -- "Not Stable & T < duration" --> TickLoop
        CheckStable -- "Stable or Timeout" --> FinalMetrics
    end

    API_Gateway --> Simulation_Pipeline
```

---

## 4. Mathematical Model & Cascade Propagation Formulas

The urban service infrastructure is represented as a directed graph:
\[
G = (V, E)
\]
Where:
- \( V \) = Set of municipal infrastructure services (Power Grid, Hospital, Water Supply, Transport, Telecommunications, Emergency, Residential, Commercial).
- \( E \) = Set of directed dependency edges \( (u, v) \in E \), indicating that service \( v \) depends on upstream service \( u \).
- \( w_{u \to v} \in (0, 1] \) = Weight / strength of the dependency.

### 4.1 Upstream Stress Function
For any service \( v \in V \) at simulation tick \( t \), incoming upstream stress is defined as:
\[
\text{Stress}(v, t) = \sum_{u \in \text{Upstream}(v)} w_{u \to v} \cdot C(\text{State}(u, t))
\]

Where the state stress contribution factor \( C(\text{State}) \) is:
\[
C(\text{State}) = \begin{cases} 
1.0 & \text{if } \text{State} = \text{FAILED} \\
0.5 & \text{if } \text{State} = \text{DEGRADED} \\
0.25 & \text{if } \text{State} = \text{RECOVERING} \\
0.0 & \text{if } \text{State} \in \{\text{HEALTHY}, \text{RECOVERED}\}
\end{cases}
\]

### 4.2 State Evaluation Thresholds
- **DEGRADED Threshold:** \(\text{Stress}(v, t) \ge 0.5 \implies \text{State}(v, t) = \text{DEGRADED}\)
- **FAILED Threshold:** \(\text{Stress}(v, t) \ge 1.0 \implies \text{State}(v, t) = \text{FAILED}\)

### 4.3 Cascade Depth & Metrics Calculation
- **Cascade Depth:** The maximum shortest-path distance in the dependency DAG from any initial disruption root \( r \in R \) to any affected node \( a \in A \):
\[
\text{Depth} = \max_{a \in A} \left( \min_{r \in R} \text{dist}(r, a) \right)
\]
- **System Impact Percentage:**
\[
\text{Impact } \% = \left( \frac{|A|}{|V|} \right) \times 100
\]

---

## 5. Database Entity-Relationship Model (ERD)

```mermaid
erDiagram
    SERVICES ||--o{ DEPENDENCIES : "source_service"
    SERVICES ||--o{ DEPENDENCIES : "target_service"
    SERVICES ||--o{ SCENARIO_SERVICES : "customizes"
    SCENARIOS ||--o{ SCENARIO_SERVICES : "configures"
    SCENARIOS ||--o{ SCENARIO_DISRUPTIONS : "defines"
    SCENARIOS ||--o{ SIMULATIONS : "executed_in"
    SIMULATIONS ||--o{ SIMULATION_EVENTS : "generates"
    SIMULATIONS ||--o{ SIMULATION_SNAPSHOTS : "records"
    SIMULATIONS ||--|| SIMULATION_METRICS : "produces"

    SERVICES {
        uuid id PK
        string name
        string slug
        string category
        string criticality
        string default_state
        int recovery_duration
        timestamp created_at
        timestamp updated_at
    }

    DEPENDENCIES {
        uuid id PK
        uuid source_service_id FK
        uuid target_service_id FK
        string dependency_type
        float dependency_strength
        float failure_threshold
        timestamp created_at
    }

    SCENARIOS {
        uuid id PK
        string name
        string description
        int seed
        int duration_seconds
        int tick_seconds
        jsonb configuration_json
        timestamp created_at
        timestamp updated_at
    }

    SCENARIO_DISRUPTIONS {
        uuid id PK
        uuid scenario_id FK
        uuid service_id FK
        int start_time
        float severity
        int duration
        jsonb configuration_json
    }

    SIMULATIONS {
        uuid id PK
        uuid scenario_id FK
        string status
        int completed_at
        timestamp created_at
    }

    SIMULATION_EVENTS {
        uuid id PK
        uuid simulation_id FK
        int simulation_time
        uuid service_id FK
        string event_type
        string previous_state
        string new_state
        string reason
    }

    SIMULATION_SNAPSHOTS {
        uuid id PK
        uuid simulation_id FK
        int simulation_time
        jsonb state_json
    }

    SIMULATION_METRICS {
        uuid id PK
        uuid simulation_id FK
        int affected_services
        int cascade_depth
        int recovery_time
        float system_impact_percentage
    }
```

---

## 6. Service State Machine & Lifecycle Transitions

Each infrastructure node transitions through discrete states based on external disruptions, incoming dependency stress, and active recovery interventions.

```mermaid
stateDiagram-v2
    [*] --> HEALTHY
    
    HEALTHY --> DEGRADED: Stress >= 0.5 OR Partial Disruption (Severity >= 0.5)
    HEALTHY --> FAILED: Stress >= 1.0 OR Critical Disruption (Severity = 1.0)
    
    DEGRADED --> FAILED: Stress >= 1.0 OR Escalating Disruption
    DEGRADED --> HEALTHY: Upstream Heals (Stress < 0.5)
    
    FAILED --> RECOVERING: Operator Initiates Recovery Action
    
    RECOVERING --> RECOVERED: Recovery Duration Elapsed (Ticks Remaining = 0)
    RECOVERING --> FAILED: Upstream Failure Re-occurs
    
    RECOVERED --> HEALTHY: Transition Phase Stabilized
```

---

## 7. End-to-End Simulation Execution Sequence

```mermaid
sequenceDiagram
    autonumber
    actor User as Urban Operator / User
    participant UI as Mobile / Web Client
    participant Controller as State Controller
    participant API as Express REST API
    participant Engine as Simulation Engine
    participant DB as PostgreSQL / Memory Store

    User->>UI: Selects "Power Grid Failure Demo" & Clicks "Run Simulation"
    UI->>Controller: triggerRunSimulation(scenarioConfig)
    
    alt Online API Mode
        Controller->>API: POST /api/simulations/run { scenarioId, disruptions }
        API->>DB: Fetch latest Service Graph & Dependencies
        DB-->>API: Graph Nodes & Edges
        API->>Engine: runSimulation(graph, disruptions, config)
        Engine->>Engine: Run propagation ticks until stabilization
        Engine-->>API: Return { events, snapshots, metrics }
        API->>DB: Persist Simulation Run, Snapshots & Metrics
        API-->>Controller: 200 OK with SimulationResult JSON
    else Offline / Fallback Mode
        Controller->>Engine: runLocalSimulation(localSeed, disruptions)
        Engine->>Engine: Execute deterministic propagation loop
        Engine-->>Controller: Return SimulationResult
    end

    Controller->>UI: Update Graph Node Visuals & Status Colors
    Controller->>UI: Populate Analytics Cards (Affected, Depth, Recovery Time, Impact)
    Controller->>UI: Stream Events to Horizontal Timeline (T+0s -> T+Ns)
    User->>UI: Tap on Recover Action for "Power Grid"
    UI->>Controller: triggerRecovery("svc-power")
    Controller->>Engine: Apply recovery & de-escalate dependent stresses
    Controller->>UI: Render live recovery progress bar & status transitions
```

---

## 8. Cross-Cutting Architectural Principles

1. **Deterministic Reproducibility:** Every scenario uses a seed value and deterministic evaluation loop ensuring identical outcomes across mobile, web, and backend runtimes.
2. **Zero-Lag Offline Resilience:** When network connectivity is absent or PostgreSQL is offline, clients seamlessly fall back to local seed data and client-side simulation.
3. **Layered Separation of Concerns:** UI widgets are strictly decoupled from propagation algorithms and HTTP clients via `ChangeNotifier` state controllers.
4. **Bi-directional Cascade Modeling:** Models both downstream cascading failure and upstream recovery cascade de-escalation.
