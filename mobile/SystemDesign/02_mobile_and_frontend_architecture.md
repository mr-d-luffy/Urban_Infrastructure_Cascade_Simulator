# 02 — Mobile & Web Client Architecture

The client presentation layer provides responsive, accessible, and high-performance interactive interfaces for inspecting and executing urban cascade simulations.

```mermaid
flowchart LR
    subgraph MobileArchitecture["Flutter Mobile App Architecture (mobile/lib/)"]
        direction TB
        M_View["Widgets & Screens<br/>• HomeScreen (Unified Dashboard)<br/>• InteractiveViewer Graph Canvas<br/>• MetricCards & SimulationProgressBar<br/>• Controls, Pickers & Timeline Log"]
        M_Ctrl["ChangeNotifier State Controllers<br/>• SimulationController (Simulation & Playback State)<br/>• ThemeController (Light / Dark Theme)"]
        M_Eng["Edge Deterministic Simulation Engine (Dart)<br/>• PropagationEngine (Stress Calculation)<br/>• RecoveryEngine (Recovery Progression)<br/>• MetricsCalculator (Cascade Depth BFS)"]
        M_API["API Client Layer (ApiService)<br/>• Dynamic Endpoint Config (ApiConfig)<br/>• Real-time Backend Health Polling"]

        M_View <--> M_Ctrl
        M_Ctrl <--> M_Eng
        M_Ctrl <--> M_API
    end

    subgraph WebArchitecture["React Web App Architecture (frontend/src/)"]
        direction TB
        W_View["React UI Components<br/>• Cinematic Hero Landing<br/>• SimulatorWorkspace<br/>• @xyflow/react Graph Canvas<br/>• ScenarioManager & Timeline Bar"]
        W_Hook["Custom React Hooks<br/>• useSimulation (State & Step Dispatcher)<br/>• useGraph (Node/Edge Transforms)<br/>• useTheme (Tailwind Dark Mode)"]
        W_Eng["Client Simulation Engine (TypeScript)<br/>• engine.ts (Main Tick Loop)<br/>• propagation.ts & recovery.ts<br/>• metrics.ts"]
        W_API["API Client Layer (api.ts)<br/>• Axios / Fetch REST Wrapper<br/>• Health & Fallback Handler"]

        W_View <--> W_Hook
        W_Hook <--> W_Eng
        W_Hook <--> W_API
    end
```

---

## Component Responsibilities

### 1. Flutter Mobile Application (`mobile/lib/`)
- **`config/app_theme.dart`**: Unified design system tokens, Navy/Canvas palette, custom status colors (`#2E8B57` Success, `#C94B4B` Critical, `#D49A2A` Warning).
- **`widgets/graph/graph_canvas.dart`**: Custom-rendered touch canvas with `InteractiveViewer`, animated pulse curves, and bottom sheet service inspection.
- **`providers/simulation_controller.dart`**: Central orchestrator managing tick playback (Play, Pause, Step, Reset), scenario selection, and local/remote engine switching.
- **`services/api_service.dart`**: Robust HTTP client featuring connection auto-probing and graceful fallback to local seed data.

### 2. React Web Dashboard (`frontend/src/`)
- **`components/cinematic/`**: Scroll-driven storytelling hero introducing smart city infrastructure dependencies.
- **`components/graph/`**: Flow graph powered by `@xyflow/react` with custom status nodes and directional edges.
- **`components/simulation/`**: Controls for injecting disruptions, initiating recovery actions, and managing saved scenarios.
- **`components/timeline/`**: Horizontal timeline tracking state transition events by simulation second (\(T+Xs\)).
