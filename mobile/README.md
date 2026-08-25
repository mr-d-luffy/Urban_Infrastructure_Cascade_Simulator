# Urban Infrastructure Cascade Simulator — Mobile App (Flutter)

A cross-platform Flutter mobile frontend for the **Urban Infrastructure Cascade Simulator**. The mobile app replicates the exact design system, theme, typography, and interactive capabilities of the web dashboard while providing mobile-optimized touch controls, zoomable pan/zoom graph canvas, and high-performance offline deterministic simulation.

---

## Key Features

1. **Exact Design System & Themes (`design.md`)**:
   - **Primary Navy** (`#1D3045`), **Dark Canvas** (`#0B131C` / `#132230`), **Surface** (`#F5F7F8`).
   - Status color-coding: Success (`#2E8B57`), Warning (`#D49A2A`), Critical (`#C94B4B`), Degraded (`#C98A35`), Neutral (`#7B8794`).
   - Seamless one-tap Light / Dark mode toggle.
2. **Cinematic Hero**:
   - Vector city skyline with animated topology lines and pulse propagation.
   - Stage progression tracker (`CITY` → `NETWORK` → `FAILURE` → `CASCADE` → `SIMULATION`).
   - Smooth scroll into the simulation workspace.
3. **Interactive Infrastructure Dependency Graph**:
   - Touch-optimized `InteractiveViewer` with smooth pan, pinch-to-zoom, and fit-view toolbar controls.
   - Custom-painted directed dependency curves with animated pulsating failure propagation arrows.
   - Tap-to-inspect service cards opening a comprehensive bottom sheet with upstream/downstream dependency navigation.
4. **Cascade Analytics Metrics Grid**:
   - **Affected Services** (with critical services count).
   - **Cascade Depth** (shortest path propagation depth).
   - **Recovery Time** (formatted as `Xm Ys` or `Xs`).
   - **System Impact %** (with total services count).
5. **Simulation & Recovery Controls**:
   - Multi-service disruption selector at `T+0`.
   - Recovery target picker with cascade de-escalation support.
   - Quick one-tap "Power Grid Failure Demo" loader.
6. **Scenario Manager**:
   - Save custom disruption scenarios to backend PostgreSQL/Memory store (or local cache).
   - Load, duplicate, and delete saved scenarios.
7. **Timeline & Live Event Stream**:
   - Interactive horizontal phase markers (Failure, Propagation, Recovery, Stabilized).
   - Tap to inspect detailed state transitions per phase.
   - Reverse-chronological event log with timestamps `T+Xs`.
8. **Backend API Integration with Zero-Lag Offline Fallback**:
   - Connects to Express REST API at `http://10.0.2.2:5000` (Android emulator) or `http://localhost:5000`.
   - In-app endpoint configuration dialog with real-time health indicator (`POSTGRESQL CONNECTED`, `IN-MEMORY FALLBACK`, `OFFLINE ENGINE`).

---

## Project Structure

```text
mobile/
├── pubspec.yaml
├── lib/
│   ├── main.dart                          # App root with MultiProvider & Theme Consumer
│   ├── config/
│   │   ├── app_theme.dart                 # Color palette, themes, icons, typography
│   │   └── api_config.dart                # Endpoint configuration & storage
│   ├── models/
│   │   ├── service_model.dart             # Infrastructure Service model
│   │   ├── dependency_model.dart          # Directed dependency model
│   │   ├── scenario_model.dart            # Scenario & Disruption models
│   │   ├── simulation_event.dart          # Time-stamped transition events
│   │   └── simulation_metrics.dart        # Cascade analytics metrics
│   ├── services/
│   │   └── api_service.dart               # HTTP client with health check & fallback
│   ├── simulation/
│   │   ├── seed_data.dart                 # 8 urban infrastructure services & dependencies
│   │   ├── simulation_types.dart          # Context, snapshots, runtimes
│   │   ├── propagation_engine.dart        # Upstream stress & failure propagation
│   │   ├── recovery_engine.dart           # Multi-tick recovery & de-escalation
│   │   ├── metrics_calculator.dart        # Cascade depth & impact calculations
│   │   └── simulation_engine.dart         # Deterministic tick-based cascade engine
│   ├── providers/
│   │   ├── simulation_controller.dart     # Central simulation & playback state
│   │   └── theme_controller.dart          # Theme switching (Light/Dark)
│   ├── widgets/
│   │   ├── cinematic/                     # Hero, NavBar, CityBackdropPainter
│   │   ├── graph/                         # Graph canvas, painter, nodes, details sheet
│   │   ├── metrics/                       # Metric cards, grid, progress bar
│   │   ├── simulation/                    # Controls, DisruptionPicker, RecoveryPicker, ScenarioManager
│   │   ├── timeline/                      # Timeline markers & Event tiles
│   │   └── common/                        # Buttons, StatusBadges, EndpointDialog
│   └── screens/
│       └── home_screen.dart               # Unified responsive dashboard screen
└── test/
    ├── simulation_engine_test.dart        # Unit tests verifying cascade propagation
    ├── metrics_test.dart                  # Unit tests for metrics calculation
    └── widget_test.dart                   # Widget test verifying main UI hierarchy
```

---

## Running the Application

### 1. Prerequisites
- Flutter SDK 3.13+ (or 3.47+)
- Android Emulator or physical device / iOS Simulator

### 2. Start Backend Server (Optional)
From the project root:
```bash
cd backend
npm run dev
```

### 3. Run Flutter App
From the `mobile/` directory:
```bash
cd mobile
flutter pub get
flutter run
```

### 4. Running Tests & Static Analysis
```bash
flutter analyze
flutter test
```
