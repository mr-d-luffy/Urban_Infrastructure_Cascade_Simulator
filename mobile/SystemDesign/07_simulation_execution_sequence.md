# 07 — End-to-End Simulation Execution Sequence

This sequence diagram illustrates the complete interactive workflow when a user selects a disruption scenario, triggers the simulation, reviews cascade metrics, and performs targeted recovery actions.

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

## Execution Stages Detailed

1. **Disruption Injection (\(T=0\))**:
   - Initial root disruptions are applied (e.g. `svc-power` receives Severity \(1.0 \implies \text{FAILED}\)).
2. **Cascade Propagation (\(T=1 \dots K\))**:
   - Each tick evaluates upstream stress on all connected services.
   - Hospital, Water Supply, Transport, and Telecommunications degrade and fail in cascade order.
3. **Stabilization Check (\(T=K+1 \dots K+3\))**:
   - Engine counts consecutive ticks with zero state transitions. Upon 3 unchanged ticks, emits `STABILIZED` event and stops.
4. **Analytics Extraction**:
   - Calculates shortest-path cascade depth via BFS.
   - Computes total affected count and percentage of municipal infrastructure impacted.
5. **Interactive Recovery**:
   - Operator initiates recovery. The engine decrements remaining repair ticks and gradually eases stress on downstream services until normal operation is restored.
