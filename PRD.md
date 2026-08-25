# PRD --- Urban Infrastructure Cascade Simulator

## 1. Product Overview

**Project:** Urban Infrastructure Cascade Simulator\
**Problem Statement:** S-03 --- Urban Infrastructure Cascade Simulator\
**Category:** Smart Cities & Urban Infrastructure\
**Product Type:** Interactive web application / simulation dashboard

Urban services are interconnected. A failure in one digital or
operational service can propagate into other services, creating
cascading failures that are difficult to detect using isolated
monitoring systems.

The product will represent interdependent urban services as a dynamic
graph and simulate how disruptions propagate through the system.

The official problem constraints require: - Dynamic graph representation
of urban services and dependencies. - Time-dependent system state. -
Failure and recovery simulation. - Multiple simultaneous disruptions. -
Measurement of cascade depth, affected services, and recovery time. -
Reproducible simulation scenarios.

## 2. Product Vision

Create a cinematic, intuitive web experience that lets users understand
how failures move through an interconnected city infrastructure network.

The experience has two layers: 1. **Cinematic storytelling layer** ---
introduces the problem and visualizes the transition from a city
environment to an infrastructure network. 2. **Interactive simulation
layer** --- allows users to configure disruptions, run simulations,
observe cascade propagation, recover services, and inspect metrics.

## 3. Goals

### Primary Goals

-   Visualize urban infrastructure as an interactive dependency graph.
-   Simulate infrastructure failures and cascading effects.
-   Support multiple simultaneous disruptions.
-   Represent system state over simulation time.
-   Simulate recovery actions.
-   Calculate cascade depth, affected services, and recovery time.
-   Provide reproducible scenarios.
-   Make complex infrastructure behavior understandable through a
    polished UI.

### Secondary Goals

-   Provide a strong hackathon demonstration.
-   Keep implementation primarily within web development.
-   Make simulations deterministic when the same scenario and
    configuration are used.
-   Provide useful analytics without requiring real-world infrastructure
    connections.

## 4. Non-Goals

The MVP will not: - Connect to real city infrastructure. - Control
real-world devices. - Perform real network attacks. - Require physical
IoT hardware. - Claim to predict real-world disasters. - Depend on
proprietary municipal datasets. - Require a machine-learning model for
the core simulation.

## 5. Target Users

### 5.1 Evaluator / Judge

Needs to quickly understand: - The problem. - Why infrastructure
dependencies matter. - What happens when a service fails. - How the
simulator measures impact.

### 5.2 Urban Planning / Infrastructure Analyst

Needs: - Service dependency visualization. - Scenario creation. -
Failure propagation. - Recovery analysis. - Historical scenario
comparison.

### 5.3 Student / Developer

Needs: - Easy-to-understand graph data. - Reproducible simulations. -
Clear API and database structure.

## 6. Core User Journey

1.  User opens the application.
2.  Cinematic hero introduces cascading infrastructure failures.
3.  User enters the interactive simulator.
4.  User selects or creates a city scenario.
5.  User views the infrastructure dependency graph.
6.  User selects one or more services to disrupt.
7.  User configures failure timing/severity if supported.
8.  User starts the simulation.
9.  The graph animates failure propagation.
10. User watches the timeline.
11. Dashboard calculates:
    -   Affected services.
    -   Cascade depth.
    -   Recovery time.
    -   Current system impact.
12. User applies recovery actions.
13. Simulation stabilizes.
14. User reviews results.
15. User can save and reproduce the scenario.

## 7. MVP Features

### 7.1 Cinematic Landing Experience

-   Full viewport hero.
-   Scroll-driven visual transition.
-   Minimal navigation.
-   Infrastructure-focused copy.
-   Transition from cinematic visual to simulator.

### 7.2 Infrastructure Graph

Nodes represent services such as: - Power Grid - Water Supply -
Hospital - Emergency Services - Public Transport - Residential Areas -
Communication Network - Waste Management - Industrial Services

Edges represent dependencies.

### 7.3 Service Details

Each service can expose: - Name. - Category. - Status. - Criticality. -
Dependencies. - Dependents. - Recovery state.

### 7.4 Failure Simulation

Users can: - Select one service. - Select multiple services. - Trigger a
disruption. - Start the simulation. - Observe propagation.

### 7.5 Recovery Simulation

Users can: - Select affected services. - Trigger recovery. - Observe
recovery propagation. - Measure recovery duration.

### 7.6 Simulation Timeline

Show: - Simulation start. - Failure events. - Propagation events. -
Recovery events. - Stabilization.

### 7.7 Metrics

Minimum required: - Cascade depth. - Affected services. - Recovery time.

Recommended supporting metrics: - Total services. - Failed services. -
Recovered services. - Critical services affected. - Overall impact
percentage.

### 7.8 Reproducible Scenarios

A scenario stores: - Graph configuration. - Initial service states. -
Disruptions. - Timing. - Recovery actions. - Simulation configuration.

Running the same scenario should produce the same result when
deterministic mode is enabled.

## 8. Functional Requirements

### FR-01 Dynamic Graph

The system must represent services and dependencies as a graph.

### FR-02 Time-Dependent State

Every simulation step must be associated with simulation time.

### FR-03 Failure Propagation

A failed service can affect dependent services according to configured
dependency rules.

### FR-04 Multiple Disruptions

The simulation must support multiple simultaneous disruptions.

### FR-05 Recovery

Users must be able to apply recovery actions to affected services.

### FR-06 Metrics

The system must calculate cascade depth, affected services, and recovery
time.

### FR-07 Scenario Reproduction

A saved scenario must contain enough information to run the same
simulation again.

### FR-08 Visualization

The graph must communicate healthy, degraded, failed, recovering, and
recovered states.

### FR-09 Simulation History

Important simulation events must be available through a timeline.

### FR-10 Reset

Users must be able to reset the simulation to its initial state.

## 9. Non-Functional Requirements

-   Responsive desktop and mobile UI.
-   Smooth graph animation.
-   Accessible controls and readable contrast.
-   Deterministic simulation mode.
-   Clear error handling.
-   No dependence on live infrastructure.
-   Modular frontend and backend.
-   Maintainable TypeScript code.
-   API validation.
-   Database constraints for data integrity.

## 10. Success Criteria

The MVP is successful when a judge can: 1. Understand the problem within
30 seconds. 2. See the infrastructure dependency graph. 3. Trigger
multiple failures. 4. Observe a visible cascade. 5. See the timeline
change with simulation time. 6. See affected services and cascade depth.
7. Perform recovery. 8. See recovery time. 9. Re-run the same scenario
and reproduce the result.

## 11. Suggested Demo Scenario

**Scenario: City Power Failure**

Initial: - Power Grid: Healthy - Hospital: Healthy - Transport:
Healthy - Water Supply: Healthy - Emergency Services: Healthy

Disruption: - Power Grid fails at T+0.

Expected cascade: - Hospital becomes degraded/failed. - Water
infrastructure becomes degraded. - Transport becomes degraded. -
Emergency services become impacted.

Recovery: - Power Grid recovery begins. - Dependent services recover
according to configured recovery rules.

Result: - Affected services. - Maximum cascade depth. - Recovery time. -
Final system state.

## 12. Future Features

-   Scenario comparison.
-   Risk scoring.
-   Dependency editing.
-   Custom city builder.
-   Import/export scenarios.
-   More advanced dependency rules.
-   Historical simulation analytics.
-   User accounts and collaboration.
-   Optional AI-assisted scenario generation.

## 13. Source-of-Truth Rule

This PRD defines product scope. Changes to features, requirements, or
project goals must be reflected here before implementation proceeds.
