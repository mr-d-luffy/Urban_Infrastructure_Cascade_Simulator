import '../models/dependency_model.dart';
import '../models/simulation_event.dart';

class ServiceRuntime {
  final String id;
  String state; // HEALTHY, DEGRADED, FAILED, RECOVERING, RECOVERED
  double stress;
  bool disrupted;
  int? firstAffectedTime;
  int? recoveryTicksRemaining;

  ServiceRuntime({
    required this.id,
    this.state = 'HEALTHY',
    this.stress = 0.0,
    this.disrupted = false,
    this.firstAffectedTime,
    this.recoveryTicksRemaining,
  });

  ServiceRuntime clone() {
    return ServiceRuntime(
      id: id,
      state: state,
      stress: stress,
      disrupted: disrupted,
      firstAffectedTime: firstAffectedTime,
      recoveryTicksRemaining: recoveryTicksRemaining,
    );
  }
}

class SimulationSnapshot {
  final int simulationTime;
  final Map<String, String> states;
  final Map<String, double> stress;

  const SimulationSnapshot({
    required this.simulationTime,
    required this.states,
    required this.stress,
  });
}

class SimulationConfig {
  final int seed;
  final int durationSeconds;
  final int tickSeconds;

  const SimulationConfig({
    this.seed = 42003,
    this.durationSeconds = 60,
    this.tickSeconds = 1,
  });
}

class SimulationResult {
  final List<SimulationEvent> events;
  final List<SimulationSnapshot> snapshots;
  final Map<String, String> finalStates;
  final Map<String, ServiceRuntime> runtimeStates;
  final int affectedServices;
  final int cascadeDepth;
  final int recoveryTime;
  final int completedAt;
  final int firstDisruptionTime;

  const SimulationResult({
    required this.events,
    required this.snapshots,
    required this.finalStates,
    required this.runtimeStates,
    required this.affectedServices,
    required this.cascadeDepth,
    required this.recoveryTime,
    required this.completedAt,
    required this.firstDisruptionTime,
  });
}

class RecoveryAction {
  final String serviceId;
  final int startTime;

  const RecoveryAction({
    required this.serviceId,
    required this.startTime,
  });
}

Map<String, ServiceRuntime> createRuntimeStates(List<String> serviceIds) {
  final map = <String, ServiceRuntime>{};
  for (final id in serviceIds) {
    map[id] = ServiceRuntime(id: id);
  }
  return map;
}

Map<String, List<DependencyModel>> buildUpstreamMap(List<DependencyModel> dependencies) {
  final map = <String, List<DependencyModel>>{};
  for (final dep in dependencies) {
    map.putIfAbsent(dep.targetServiceId, () => []).add(dep);
  }
  return map;
}

Map<String, List<String>> buildDownstreamMap(List<DependencyModel> dependencies) {
  final map = <String, List<String>>{};
  for (final dep in dependencies) {
    map.putIfAbsent(dep.sourceServiceId, () => []).add(dep.targetServiceId);
  }
  return map;
}

SimulationSnapshot snapshotFromRuntime(int time, Map<String, ServiceRuntime> runtimes) {
  final states = <String, String>{};
  final stress = <String, double>{};
  for (final entry in runtimes.entries) {
    states[entry.key] = entry.value.state;
    stress[entry.key] = entry.value.stress;
  }
  return SimulationSnapshot(
    simulationTime: time,
    states: states,
    stress: stress,
  );
}

String eventTypeForTransition(String previous, String next) {
  if (next == 'FAILED') {
    return previous == 'HEALTHY' ? 'FAILURE' : 'PROPAGATION';
  }
  if (next == 'DEGRADED') return 'DEGRADATION';
  return 'PROPAGATION';
}

void markAffected(ServiceRuntime runtime, int time, String nextState) {
  if (runtime.firstAffectedTime == null &&
      (nextState == 'DEGRADED' || nextState == 'FAILED')) {
    runtime.firstAffectedTime = time;
  }
}
