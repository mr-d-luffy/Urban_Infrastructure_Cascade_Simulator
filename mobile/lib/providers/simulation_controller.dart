import 'dart:async';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/dependency_model.dart';
import '../models/scenario_model.dart';
import '../models/service_model.dart';
import '../models/simulation_event.dart';
import '../models/simulation_metrics.dart';
import '../services/api_service.dart';
import '../simulation/metrics_calculator.dart';
import '../simulation/recovery_engine.dart';
import '../simulation/seed_data.dart';
import '../simulation/simulation_engine.dart';
import '../simulation/simulation_types.dart';

const int playbackMs = 700;

class SimulationController extends ChangeNotifier {
  List<ServiceModel> _services = [];
  List<DependencyModel> _dependencies = [];
  String? _selectedId;
  List<DisruptionModel> _disruptions = [];
  List<String> _recoveryTargets = [];
  String _status = 'IDLE'; // IDLE, RUNNING, COMPLETED, FAILED
  String _phase = 'idle';  // idle, failure, recovery, complete
  int _simulationTime = 0;
  List<SimulationEvent> _events = [];
  SimulationMetrics? _metrics;
  int _totalDuration = 0;
  List<String> _activeEdgeIds = [];
  String? _error;
  String _connectionState = 'checking'; // checking, postgres, memory, offline
  List<ScenarioModel> _scenarios = [];
  bool _isLoadingScenarios = false;
  String _customApiUrl = '';

  Timer? _playbackTimer;
  Map<String, ServiceRuntime>? _runtimeStates;
  int _failureCompletedAt = 0;
  int _firstDisruptionTime = 0;

  // Getters
  List<ServiceModel> get services => _services;
  List<DependencyModel> get dependencies => _dependencies;
  String? get selectedId => _selectedId;
  ServiceModel? get selectedService =>
      _services.where((s) => s.id == _selectedId).firstOrNull;
  List<DisruptionModel> get disruptions => _disruptions;
  List<String> get recoveryTargets => _recoveryTargets;
  String get status => _status;
  String get phase => _phase;
  int get simulationTime => _simulationTime;
  List<SimulationEvent> get events => _events;
  SimulationMetrics? get metrics =>
      computeDisplayMetrics(_metrics, _services, _events, _phase);
  int get totalDuration => _totalDuration;
  List<String> get activeEdgeIds => _activeEdgeIds;
  String? get error => _error;
  String get connectionState => _connectionState;
  List<ScenarioModel> get scenarios => _scenarios;
  bool get isLoadingScenarios => _isLoadingScenarios;
  String get customApiUrl => _customApiUrl;

  List<ServiceModel> get upstreamServices {
    if (_selectedId == null) return [];
    final upstreamDeps = _dependencies.where((d) => d.targetServiceId == _selectedId);
    final upstreamIds = upstreamDeps.map((d) => d.sourceServiceId).toSet();
    return _services.where((s) => upstreamIds.contains(s.id)).toList();
  }

  List<ServiceModel> get downstreamServices {
    if (_selectedId == null) return [];
    final downstreamDeps = _dependencies.where((d) => d.sourceServiceId == _selectedId);
    final downstreamIds = downstreamDeps.map((d) => d.targetServiceId).toSet();
    return _services.where((s) => downstreamIds.contains(s.id)).toList();
  }

  List<ServiceModel> get recoverableServices {
    return _services
        .where((s) => s.state == 'FAILED' || s.state == 'DEGRADED')
        .toList();
  }

  SimulationController() {
    _init();
  }

  Future<void> _init() async {
    _services = List.from(seedServices);
    _dependencies = List.from(seedDependencies);
    _customApiUrl = await ApiConfig.getBaseUrl();
    notifyListeners();

    await checkBackendHealth();
    await fetchBackendGraphData();
    await fetchScenarios();
  }

  Future<void> checkBackendHealth() async {
    _connectionState = 'checking';
    notifyListeners();

    final healthRes = await ApiService.health();
    if (healthRes.success && healthRes.data != null) {
      _connectionState = healthRes.data!.databaseConnected ? 'postgres' : 'memory';
    } else {
      _connectionState = 'offline';
    }
    notifyListeners();
  }

  Future<void> setCustomApiUrl(String url) async {
    await ApiConfig.setBaseUrl(url);
    _customApiUrl = url;
    await checkBackendHealth();
    await fetchBackendGraphData();
    await fetchScenarios();
    notifyListeners();
  }

  Future<void> fetchBackendGraphData() async {
    final resServices = await ApiService.getServices();
    final resDeps = await ApiService.getDependencies();

    if (resServices.success && resServices.data != null && resServices.data!.isNotEmpty) {
      final posMap = {for (final s in seedServices) s.slug: s.position};
      _services = resServices.data!.map((s) {
        return s.copyWith(
          position: posMap[s.slug] ?? s.position,
          state: 'HEALTHY',
        );
      }).toList();
    }

    if (resDeps.success && resDeps.data != null && resDeps.data!.isNotEmpty) {
      _dependencies = resDeps.data!;
    }
    notifyListeners();
  }

  Future<void> fetchScenarios() async {
    _isLoadingScenarios = true;
    notifyListeners();

    final res = await ApiService.getScenarios();
    if (res.success && res.data != null) {
      _scenarios = res.data!;
    }
    _isLoadingScenarios = false;
    notifyListeners();
  }

  void selectService(String? id) {
    if (_status == 'RUNNING') return;
    _selectedId = id;
    notifyListeners();
  }

  void toggleDisruption(String serviceId) {
    if (_status == 'RUNNING' || _phase == 'failure' || _phase == 'recovery' || _phase == 'complete') {
      return;
    }

    final exists = _disruptions.any((d) => d.serviceId == serviceId);
    if (exists) {
      _disruptions = _disruptions.where((d) => d.serviceId != serviceId).toList();
    } else {
      _disruptions = [..._disruptions, DisruptionModel(serviceId: serviceId, startTime: 0, severity: 1.0)];
    }
    _error = null;
    notifyListeners();
  }

  void toggleRecoveryTarget(String serviceId) {
    if (_status == 'RUNNING') return;

    if (_recoveryTargets.contains(serviceId)) {
      _recoveryTargets = _recoveryTargets.where((id) => id != serviceId).toList();
    } else {
      _recoveryTargets = [..._recoveryTargets, serviceId];
    }
    _error = null;
    notifyListeners();
  }

  void loadDemoScenario() {
    if (_status == 'RUNNING') return;
    final demo = createPowerGridFailureScenario();
    _disruptions = demo.disruptions;
    _recoveryTargets = [];
    _selectedId = 'svc-power';
    _phase = 'idle';
    _error = null;
    notifyListeners();
  }

  void loadScenario(ScenarioModel scenario) {
    if (_status == 'RUNNING') return;
    resetSimulation();
    _disruptions = List.from(scenario.disruptions);
    notifyListeners();
  }

  Future<void> saveScenario(String name) async {
    if (name.trim().isEmpty) {
      _error = 'Enter a scenario name.';
      notifyListeners();
      return;
    }

    final scenario = ScenarioModel(
      id: 'scen-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      disruptions: _disruptions,
    );

    final res = await ApiService.createScenario(scenario);
    if (res.success && res.data != null) {
      _scenarios.insert(0, res.data!);
    } else {
      // Offline fallback: save locally in scenarios list
      _scenarios.insert(0, scenario);
    }
    _error = null;
    notifyListeners();
  }

  Future<void> duplicateScenario(ScenarioModel scenario) async {
    final copy = scenario.copyWith(
      id: 'scen-${DateTime.now().millisecondsSinceEpoch}',
      name: '${scenario.name} copy',
    );
    final res = await ApiService.createScenario(copy);
    if (res.success && res.data != null) {
      _scenarios.insert(0, res.data!);
    } else {
      _scenarios.insert(0, copy);
    }
    notifyListeners();
  }

  Future<void> deleteScenario(String id) async {
    await ApiService.deleteScenario(id);
    _scenarios.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void resetSimulation() {
    _stopPlayback();
    _services = _services.map((s) => s.copyWith(state: 'HEALTHY')).toList();
    _disruptions = [];
    _recoveryTargets = [];
    _status = 'IDLE';
    _phase = 'idle';
    _simulationTime = 0;
    _events = [];
    _metrics = null;
    _totalDuration = 0;
    _activeEdgeIds = [];
    _error = null;
    _selectedId = null;
    _runtimeStates = null;
    _failureCompletedAt = 0;
    _firstDisruptionTime = 0;
    notifyListeners();
  }

  void _stopPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  void _highlightPropagationEdges(List<SimulationEvent> tickEvents) {
    if (tickEvents.isEmpty) {
      _activeEdgeIds = [];
      notifyListeners();
      return;
    }

    final latest = tickEvents.last;
    final related = _dependencies
        .where((dep) => dep.targetServiceId == latest.serviceId)
        .map((dep) => dep.id)
        .toList();

    _activeEdgeIds = related;
    notifyListeners();

    Timer(const Duration(milliseconds: playbackMs - 100), () {
      _activeEdgeIds = [];
      notifyListeners();
    });
  }

  void _playSnapshots(
    List<SimulationSnapshot> snapshots,
    List<SimulationEvent> resultEvents,
    VoidCallback onComplete,
  ) {
    int frame = 0;
    _playbackTimer = Timer.periodic(const Duration(milliseconds: playbackMs), (timer) {
      if (frame >= snapshots.length) {
        _stopPlayback();
        _activeEdgeIds = [];
        onComplete();
        notifyListeners();
        return;
      }

      final snapshot = snapshots[frame];
      _simulationTime = snapshot.simulationTime;

      _services = _services.map((service) {
        final state = snapshot.states[service.id] ?? service.state;
        return service.copyWith(state: state);
      }).toList();

      final tickEvents = resultEvents
          .where((e) => e.simulationTime == snapshot.simulationTime)
          .toList();
      if (tickEvents.isNotEmpty) {
        _events = [..._events, ...tickEvents];
        _highlightPropagationEdges(tickEvents);
      }

      frame++;
      notifyListeners();
    });
  }

  void runSimulationPlayback() {
    if (_disruptions.isEmpty) {
      _error = 'Select at least one service to disrupt before running.';
      notifyListeners();
      return;
    }

    try {
      _stopPlayback();
      _error = null;
      _events = [];
      _metrics = null;
      _recoveryTargets = [];
      _status = 'RUNNING';
      _phase = 'failure';
      _simulationTime = 0;
      _services = _services.map((s) => s.copyWith(state: 'HEALTHY')).toList();
      notifyListeners();

      final result = runSimulation(
        serviceIds: _services.map((s) => s.id).toList(),
        dependencies: _dependencies,
        disruptions: _disruptions,
        config: const SimulationConfig(),
      );

      _runtimeStates = result.runtimeStates;
      _failureCompletedAt = result.completedAt;
      _firstDisruptionTime = result.firstDisruptionTime;
      _metrics = calculateMetrics(result, _services);
      _totalDuration = result.completedAt;

      _playSnapshots(result.snapshots, result.events, () {
        _status = 'COMPLETED';
        _phase = 'failure';
        _recoveryTargets = result.finalStates.entries
            .where((entry) => entry.value == 'FAILED' || entry.value == 'DEGRADED')
            .map((entry) => entry.key)
            .toList();
        notifyListeners();
      });
    } catch (e) {
      _status = 'FAILED';
      _phase = 'idle';
      _error = e.toString();
      _stopPlayback();
      notifyListeners();
    }
  }

  void runRecoveryPlayback() {
    if (_runtimeStates == null) {
      _error = 'Run the failure simulation before starting recovery.';
      notifyListeners();
      return;
    }

    if (_recoveryTargets.isEmpty) {
      _error = 'Select at least one service to recover.';
      notifyListeners();
      return;
    }

    try {
      _stopPlayback();
      _error = null;
      _status = 'RUNNING';
      _phase = 'recovery';
      notifyListeners();

      final recoveryActions = _recoveryTargets
          .map((id) => RecoveryAction(serviceId: id, startTime: _failureCompletedAt + 1))
          .toList();

      final recoveryDurations = buildRecoveryDurations(_services);

      final result = runRecoverySimulation(
        initialStates: _runtimeStates!,
        dependencies: _dependencies,
        recoveryActions: recoveryActions,
        recoveryDurations: recoveryDurations,
        config: const SimulationConfig(durationSeconds: 90),
        startTime: _failureCompletedAt,
        firstDisruptionTime: _firstDisruptionTime,
      );

      for (final entry in result.finalStates.entries) {
        final runtime = _runtimeStates![entry.key];
        if (runtime != null) {
          runtime.state = entry.value;
          runtime.recoveryTicksRemaining = null;
        }
      }

      if (_metrics != null) {
        _metrics = mergeRecoveryMetrics(_metrics!, result);
      }
      _totalDuration = result.completedAt;

      _playSnapshots(result.snapshots, result.events, () {
        _status = 'COMPLETED';
        _phase = 'complete';
        _recoveryTargets = [];
        notifyListeners();
      });
    } catch (e) {
      _status = 'FAILED';
      _error = e.toString();
      _stopPlayback();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopPlayback();
    super.dispose();
  }
}
