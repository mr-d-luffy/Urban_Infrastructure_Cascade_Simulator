CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  slug VARCHAR(140) UNIQUE NOT NULL,
  category VARCHAR(60) NOT NULL,
  description TEXT,
  criticality INTEGER NOT NULL DEFAULT 1 CHECK (criticality BETWEEN 1 AND 5),
  default_state VARCHAR(30) NOT NULL DEFAULT 'HEALTHY',
  recovery_duration INTEGER NOT NULL DEFAULT 60,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dependencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  target_service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  dependency_type VARCHAR(40) NOT NULL DEFAULT 'REQUIRED',
  dependency_strength DECIMAL(5,2) NOT NULL DEFAULT 1.0,
  failure_threshold DECIMAL(5,2) NOT NULL DEFAULT 0.5,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(source_service_id, target_service_id)
);

CREATE TABLE IF NOT EXISTS scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(160) NOT NULL,
  description TEXT,
  seed BIGINT NOT NULL,
  duration_seconds INTEGER NOT NULL DEFAULT 1800 CHECK (duration_seconds > 0),
  tick_seconds INTEGER NOT NULL DEFAULT 1 CHECK (tick_seconds > 0),
  configuration_json JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS scenario_disruptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID NOT NULL REFERENCES scenarios(id) ON DELETE CASCADE,
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  start_time INTEGER NOT NULL DEFAULT 0 CHECK (start_time >= 0),
  severity DECIMAL(5,2) NOT NULL DEFAULT 1.0 CHECK (severity BETWEEN 0 AND 1),
  duration INTEGER,
  configuration_json JSONB NOT NULL DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS simulations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID REFERENCES scenarios(id) ON DELETE SET NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'QUEUED',
  disruptions_json JSONB NOT NULL DEFAULT '[]',
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  simulation_duration INTEGER,
  first_disruption_time INTEGER NOT NULL DEFAULT 0,
  final_state JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS simulation_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  simulation_id UUID NOT NULL REFERENCES simulations(id) ON DELETE CASCADE,
  simulation_time INTEGER NOT NULL,
  service_id UUID REFERENCES services(id) ON DELETE SET NULL,
  event_type VARCHAR(40) NOT NULL,
  previous_state VARCHAR(30),
  new_state VARCHAR(30),
  reason TEXT,
  metadata_json JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS simulation_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  simulation_id UUID NOT NULL REFERENCES simulations(id) ON DELETE CASCADE,
  simulation_time INTEGER NOT NULL,
  state_json JSONB NOT NULL,
  affected_service_count INTEGER NOT NULL DEFAULT 0,
  cascade_depth INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS simulation_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  simulation_id UUID UNIQUE NOT NULL REFERENCES simulations(id) ON DELETE CASCADE,
  affected_services INTEGER NOT NULL DEFAULT 0,
  cascade_depth INTEGER NOT NULL DEFAULT 0,
  recovery_time INTEGER NOT NULL DEFAULT 0,
  critical_services_affected INTEGER NOT NULL DEFAULT 0,
  impact_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_dependencies_source ON dependencies(source_service_id);
CREATE INDEX IF NOT EXISTS idx_dependencies_target ON dependencies(target_service_id);
CREATE INDEX IF NOT EXISTS idx_simulation_events_simulation_time ON simulation_events(simulation_id, simulation_time);
