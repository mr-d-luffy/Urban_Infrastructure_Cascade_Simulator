# Project Rules --- Urban Infrastructure Cascade Simulator

## 1. Source of Truth

The following files are project source-of-truth documents:

1.  PRD.md --- What the product must do.
2.  architecture.md --- How the system is structured.
3.  database.md --- How data is stored.
4.  design.md --- How the product looks.
5.  phases.md --- What should be built and when.
6.  rules.md --- Development constraints.
7.  memory.md --- Current project state.
8.  README.md --- Project overview and setup.

If implementation conflicts with these files, stop and resolve the
documentation first.

## 2. Development Rules

### DO

-   Use TypeScript.
-   Keep components modular.
-   Keep simulation logic independent from UI.
-   Validate API input.
-   Use reusable components.
-   Keep simulation deterministic.
-   Write meaningful names.
-   Keep functions focused.
-   Handle loading/error/empty states.
-   Test core simulation logic.

### DON'T

-   Put the entire application in one component.
-   Put simulation rules directly inside UI components.
-   Hard-code database IDs.
-   Trust client-side metrics as authoritative.
-   Add unnecessary libraries.
-   Add unnecessary animations.
-   Duplicate business logic.

## 3. Simulation Rules

-   The graph must be directed.
-   Dependencies must have a clear direction.
-   State transitions must be deterministic.
-   Every simulation event must have a simulation timestamp.
-   Multiple disruptions must be supported.
-   Recovery must be represented explicitly.
-   Metrics must be calculated from simulation state/events.
-   Reset must restore the initial scenario.
-   Replaying the same deterministic scenario must produce the same
    result.

## 4. Service State Rules

Allowed states:

``` text
HEALTHY
DEGRADED
FAILED
RECOVERING
RECOVERED
```

Do not invent additional states without updating documentation.

## 5. Metric Rules

### Affected Services

Count services that entered a degraded, failed, or otherwise impacted
state during the simulation.

### Cascade Depth

Maximum dependency propagation depth reached by a disruption.

### Recovery Time

Time from initial disruption to system stabilization according to the
scenario's defined stabilization condition.

The exact formulas must remain consistent across frontend, backend, and
tests.

## 6. UI Rules

-   Do not use color as the only status indicator.
-   Avoid excessive glassmorphism.
-   Avoid excessive gradients.
-   Avoid unnecessary cards.
-   Keep the graph readable.
-   Keep primary actions obvious.
-   Do not hide critical simulation information behind decorative UI.

## 7. Cinematic Rules

The cinematic section should remain visually minimal.

Do not add: - Random logos. - Extra brands. - Cookie widgets. -
Unrelated overlays. - Unrelated sections. - Generic stock-dashboard
decorations.

The supplied cinematic video specification must be treated as fixed if
that exact implementation is chosen.

## 8. API Rules

-   Use REST conventions.
-   Validate request bodies.
-   Return consistent response structures.
-   Return meaningful HTTP status codes.
-   Never expose secrets.
-   Never expose raw database errors to users.

## 9. Database Rules

-   Use foreign keys.
-   Use parameterized queries.
-   Preserve simulation history.
-   Never overwrite completed simulation results.
-   Use migrations for schema changes.
-   Seed deterministic demo data.

## 10. Git Rules

Recommended branch structure:

``` text
main
develop
feature/*
fix/*
```

Commit format:

``` text
feat: add simulation engine
fix: correct cascade depth calculation
ui: improve graph node states
docs: update database schema
```

## 11. Dependency Rules

Before adding a package: 1. Check whether the feature can be implemented
with existing tools. 2. Check bundle impact. 3. Check maintenance
status. 4. Document why the dependency is required.

## 12. Performance Rules

-   Do not re-render the entire graph for every small UI change.
-   Keep simulation calculations outside React render cycles where
    appropriate.
-   Avoid unnecessary API requests.
-   Batch persistence where appropriate.
-   Respect reduced-motion preferences.
-   Optimize large graphs before adding visual effects.

## 13. Security Rules

-   Environment secrets stay outside source control.
-   Validate all user input.
-   Use secure database access.
-   Configure CORS intentionally.
-   Do not expose internal stack traces in production.

## 14. Change Rules

When a requirement changes: 1. Update the relevant MD file. 2. Update
memory.md. 3. Review affected architecture/database/design. 4. Only then
implement the code.

## 15. Completion Rule

A phase is not complete because code exists.

A phase is complete only when: - Feature works. - Responsive behavior is
checked. - Errors are handled. - Relevant tests pass. - Documentation is
updated. - memory.md records the result.
