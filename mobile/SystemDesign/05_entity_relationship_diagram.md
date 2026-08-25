# 05 — Database Entity-Relationship Model (ERD)

The database persistence layer is implemented in PostgreSQL and structured to enforce referential integrity across infrastructure topologies, scenario definitions, simulation execution runs, granular state snapshots, and cascade metrics.

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

    SCENARIO_SERVICES {
        uuid id PK
        uuid scenario_id FK
        uuid service_id FK
        string initial_state
        float failure_threshold
        int recovery_duration
        jsonb configuration_json
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

## Key Schema Design Decisions

1. **Self-Referencing Dependencies (`dependencies`)**: Models directed graph edges with `source_service_id` and `target_service_id` referencing `services(id)`.
2. **Deterministic Seed Storage (`scenarios.seed`)**: Stores integer seed values ensuring that stochastic disruptions or simulated jitter remain 100% reproducible.
3. **JSONB Snapshot Serialization (`simulation_snapshots.state_json`)**: Stores full system state at each tick (\(T=0, 1, 2 \dots N\)) for time-scrubbing playback.
4. **Normalized Event Stream (`simulation_events`)**: Enables granular audit logs of every individual state change with simulation timestamp and transition cause.
