# Database --- Urban Infrastructure Cascade Simulator

## 1. Database Choice

Recommended database: **PostgreSQL**

Reason: - Relational integrity. - JSONB support for flexible simulation
configuration. - Good support for structured analytics. - Easy
deployment. - Strong constraints and indexing.

## 2. Entity Relationship Overview

``` text
services
   │
   ├──────── dependencies ──────── services
   │
   └──────── scenario_services ─── scenarios
                                      │
                                      └── simulations
                                             │
                                             ├── simulation_events
                                             ├── simulation_snapshots
                                             └── simulation_metrics
```

## 3. Tables

### services

Stores infrastructure services.

``` text
id
name
slug
category
description
criticality
default_state
recovery_duration
created_at
updated_at
```

Suggested categories: - Energy - Water - Healthcare - Transport -
Emergency - Communication - Residential - Industrial - Waste

### dependencies

Stores directed service relationships.

``` text
id
source_service_id
target_service_id
dependency_type
dependency_strength
failure_threshold
created_at
```

Meaning:

``` text
source_service → target_service
```

The target depends on the source.

### scenarios

Stores reproducible simulation scenarios.

``` text
id
name
description
seed
duration_seconds
tick_seconds
configuration_json
created_at
updated_at
```

The `seed` ensures deterministic random behavior where randomness is
used.

### scenario_services

Stores scenario-specific service state/configuration.

``` text
id
scenario_id
service_id
initial_state
failure_threshold
recovery_duration
configuration_json
```

### scenario_disruptions

Stores initial disruptions.

``` text
id
scenario_id
service_id
start_time
severity
duration
configuration_json
```

### simulations

Stores each simulation run.

``` text
id
scenario_id
status
started_at
completed_at
simulation_duration
final_state
created_at
```

Statuses:

``` text
QUEUED
RUNNING
COMPLETED
FAILED
CANCELLED
```

### simulation_events

Stores time-based events.

``` text
id
simulation_id
simulation_time
service_id
event_type
previous_state
new_state
reason
metadata_json
created_at
```

Event types:

``` text
FAILURE
DEGRADATION
PROPAGATION
RECOVERY_STARTED
RECOVERY_COMPLETED
STABILIZED
```

### simulation_snapshots

Stores system state at selected simulation times.

``` text
id
simulation_id
simulation_time
state_json
affected_service_count
cascade_depth
created_at
```

### simulation_metrics

Stores final/calculated metrics.

``` text
id
simulation_id
affected_services
cascade_depth
recovery_time
critical_services_affected
impact_percentage
created_at
```

## 4. PostgreSQL Schema

``` sql
CREATE TABLE services (
  id UUID PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  slug VARCHAR(140) UNIQUE NOT NULL,
  category VARCHAR(60) NOT NULL,
  description TEXT,
  criticality INTEGER NOT NULL DEFAULT 1 CHECK (criticality BETWEEN 1 AND 5),
  default_state VARCHAR(30) NOT NULL DEFAULT 'HEALTHY',
  recovery_duration INTEGER NOT NULL DEFAULT 60,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dependencies (
  id UUID PRIMARY KEY,
  source_service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  target_service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  dependency_type VARCHAR(40) NOT NULL DEFAULT 'REQUIRED',
  dependency_strength DECIMAL(5,2) NOT NULL DEFAULT 1.0,
  failure_threshold DECIMAL(5,2) NOT NULL DEFAULT 0.5,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(source_service_id, target_service_id)
);

CREATE TABLE scenarios (
  id UUID PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  description TEXT,
  seed BIGINT NOT NULL,
  duration_seconds INTEGER NOT NULL DEFAULT 1800,
  tick_seconds INTEGER NOT NULL DEFAULT 1,
  configuration_json JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE scenario_services (
  id UUID PRIMARY KEY,
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  initial_state VARCHAR(30) NOT NULL DEFAULT 'HEALTHY',
  failure_threshold DECIMAL(5,2),
  recovery_duration INTEGER,
  configuration_json JSONB NOT NULL DEFAULT '{}',
  UNIQUE(scenario_id, service_id)
);

CREATE TABLE scenario_disruptions (
  id UUID PRIMARY KEY,
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  start_time INTEGER NOT NULL DEFAULT 0,
  severity DECIMAL(5,2) NOT NULL DEFAULT 1.0,
  duration INTEGER,
  configuration_json JSONB NOT NULL DEFAULT '{}'
);

CREATE TABLE simulations (
  id UUID PRIMARY KEY,
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL DEFAULT 'QUEUED',
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  simulation_duration INTEGER,
  final_state JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE simulation_events (
  id UUID PRIMARY KEY,
  simulation_id UUID NOT NULL REFERENCES simulations(id) ON DELETE CASCADE,
  simulation_time INTEGER NOT NULL,
  service_id UUID REFERENCES services(id) ON DELETE SET NULL,
  event_type VARCHAR(40) NOT NULL,
  previous_state VARCHAR(30),
  new_state VARCHAR(30),
  reason TEXT,
  metadata_json JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE simulation_snapshots (
  id UUID PRIMARY KEY,
  simulation_id UUID NOT NULL REFERENCES simulations(id) ON DELETE CASCADE,
  simulation_time INTEGER NOT NULL,
  state_json JSONB NOT NULL,
  affected_service_count INTEGER NOT NULL DEFAULT 0,
  cascade_depth INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE simulation_metrics (
  id UUID PRIMARY KEY,
  simulation_id UUID UNIQUE NOT NULL REFERENCES simulations(id) ON DELETE CASCADE,
  affected_services INTEGER NOT NULL DEFAULT 0,
  cascade_depth INTEGER NOT NULL DEFAULT 0,
  recovery_time INTEGER NOT NULL DEFAULT 0,
  critical_services_affected INTEGER NOT NULL DEFAULT 0,
  impact_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

## 5. Seed Infrastructure

The MVP should include a small deterministic city network.

Example:

``` text
Power Grid
├── Hospital
├── Water Supply
├── Transport
└── Communication

Hospital
└── Emergency Services

Transport
└── Emergency Services

Water Supply
└── Residential Areas
```

## 6. Database Rules

-   Use UUID primary keys.
-   Use foreign keys for relationships.
-   Use database constraints where possible.
-   Never store secrets in the database.
-   Keep simulation configuration versionable.
-   Preserve completed simulation events.
-   Do not overwrite historical simulation results.

## 7. Migrations and Demo Seed

The initial PostgreSQL schema is maintained in
`backend/migrations/001_initial_schema.sql`. Apply migrations before loading
data, then run the idempotent seed script:

``` bash
cd backend
npm run migrate
npm run seed
```

The seed script identifies services by their unique slugs and resolves their
database-generated UUIDs at insert time. This keeps the demo graph
deterministic without embedding database identifiers in application code.
