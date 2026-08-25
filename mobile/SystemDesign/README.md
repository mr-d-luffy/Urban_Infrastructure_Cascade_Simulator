# System Design & Architecture Index

This directory contains the complete architectural blueprints, design diagrams, data models, and algorithm specifications for the **Urban Infrastructure Cascade Simulator**.

---

## Architecture Documents & Diagrams

| Document | Description | Key Diagram |
| :--- | :--- | :--- |
| **[`SYSTEM_ARCHITECTURE.md`](SYSTEM_ARCHITECTURE.md)** | **Master Architectural Document** combining all system tiers, specifications, diagrams, and formulas. | End-to-End System Flow |
| **[`01_high_level_architecture.md`](01_high_level_architecture.md)** | High-level 3-tier architecture showing Clients, Express API, Simulation Engines, and Databases. | Multi-tier System Topology |
| **[`02_mobile_and_frontend_architecture.md`](02_mobile_and_frontend_architecture.md)** | Layered architecture for Flutter Mobile and React Web dashboards with offline-first design. | Client Subsystem Architecture |
| **[`03_backend_and_simulation_engine.md`](03_backend_and_simulation_engine.md)** | Backend REST API structure, controllers, and deterministic simulation execution pipeline. | API & Engine Pipeline |
| **[`04_mathematical_model_and_propagation.md`](04_mathematical_model_and_propagation.md)** | Formal graph theory definitions, upstream stress formula, thresholds, and cascade depth algorithms. | Mathematical Equations & Logic |
| **[`05_entity_relationship_diagram.md`](05_entity_relationship_diagram.md)** | PostgreSQL relational schema, JSONB snapshot formats, and table relationships. | Entity Relationship Diagram (ERD) |
| **[`06_state_machine_lifecycle.md`](06_state_machine_lifecycle.md)** | Municipal service state transitions (`HEALTHY`, `DEGRADED`, `FAILED`, `RECOVERING`, `RECOVERED`). | State Transition Diagram |
| **[`07_simulation_execution_sequence.md`](07_simulation_execution_sequence.md)** | Time-ordered sequence diagram for simulation execution, event streaming, and recovery triggers. | Execution Sequence Diagram |
