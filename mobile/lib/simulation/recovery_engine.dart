import 'dart:math' as math;
import '../models/dependency_model.dart';
import '../models/simulation_event.dart';
import 'propagation_engine.dart';
import 'simulation_types.dart';

const int defaultRecoveryDuration = 6;

bool upstreamHealthy(
  ServiceRuntime runtime,
  Map<String, ServiceRuntime> runtimeStates,
  Map<String, List<DependencyModel>> upstreamMap,
) {
  final upstream = upstreamMap[runtime.id] ?? [];
  return upstream.every((dep) {
    final source = runtimeStates[dep.sourceServiceId];
    if (source == null) return true;
    return source.state == 'HEALTHY' || source.state == 'RECOVERED';
  });
}

bool applyRecoveryStarts(
  Map<String, ServiceRuntime> runtimeStates,
  List<RecoveryAction> recoveryActions,
  int simulationTime,
  Map<String, int> recoveryDurations,
  List<SimulationEvent> events,
) {
  bool changed = false;
  final due = recoveryActions.where((action) => action.startTime == simulationTime).toList();

  for (final action in due) {
    final runtime = runtimeStates[action.serviceId];
    if (runtime == null) continue;
    if (runtime.state != 'FAILED' && runtime.state != 'DEGRADED') continue;

    final previousState = runtime.state;
    runtime.state = 'RECOVERING';
    runtime.recoveryTicksRemaining =
        recoveryDurations[action.serviceId] ?? defaultRecoveryDuration;
    runtime.stress = math.max(runtime.stress - 0.25, 0.0);

    events.add(SimulationEvent(
      simulationTime: simulationTime,
      serviceId: runtime.id,
      eventType: 'RECOVERY_STARTED',
      previousState: previousState,
      newState: 'RECOVERING',
      reason: 'Recovery action initiated',
    ));
    changed = true;
  }

  return changed;
}

bool processRecoveryProgress(
  Map<String, ServiceRuntime> runtimeStates,
  int simulationTime,
  List<SimulationEvent> events,
) {
  bool changed = false;

  for (final runtime in runtimeStates.values) {
    if (runtime.state != 'RECOVERING' || runtime.recoveryTicksRemaining == null) continue;

    runtime.recoveryTicksRemaining = runtime.recoveryTicksRemaining! - 1;
    changed = true;

    if (runtime.recoveryTicksRemaining! <= 0) {
      runtime.state = 'RECOVERED';
      runtime.recoveryTicksRemaining = null;
      runtime.disrupted = false;
      runtime.stress = 0.0;

      events.add(SimulationEvent(
        simulationTime: simulationTime,
        serviceId: runtime.id,
        eventType: 'RECOVERY_COMPLETED',
        previousState: 'RECOVERING',
        newState: 'RECOVERED',
        reason: 'Service recovery finished',
      ));
    }
  }

  return changed;
}

bool promoteRecoveredServices(
  Map<String, ServiceRuntime> runtimeStates,
  Map<String, List<DependencyModel>> upstreamMap,
  int simulationTime,
  List<SimulationEvent> events,
) {
  bool changed = false;

  for (final runtime in runtimeStates.values) {
    if (runtime.state != 'RECOVERED') continue;
    if (!upstreamHealthy(runtime, runtimeStates, upstreamMap)) continue;

    runtime.state = 'HEALTHY';
    runtime.stress = 0.0;
    events.add(SimulationEvent(
      simulationTime: simulationTime,
      serviceId: runtime.id,
      eventType: 'STABILIZED',
      previousState: 'RECOVERED',
      newState: 'HEALTHY',
      reason: 'Service returned to healthy operation',
    ));
    changed = true;
  }

  return changed;
}

bool evaluateRecoveryPropagation(
  Map<String, ServiceRuntime> runtimeStates,
  Map<String, List<DependencyModel>> upstreamMap,
  int simulationTime,
  List<SimulationEvent> events,
) {
  return evaluateDependencyPropagation(
    runtimeStates,
    upstreamMap,
    simulationTime,
    events,
    allowDeescalation: true,
  );
}

bool processRecoveryTick(
  Map<String, ServiceRuntime> runtimeStates,
  Map<String, List<DependencyModel>> upstreamMap,
  List<RecoveryAction> recoveryActions,
  Map<String, int> recoveryDurations,
  int simulationTime,
  List<SimulationEvent> events,
) {
  final started = applyRecoveryStarts(
    runtimeStates,
    recoveryActions,
    simulationTime,
    recoveryDurations,
    events,
  );
  final progressed = processRecoveryProgress(runtimeStates, simulationTime, events);
  final promoted = promoteRecoveredServices(
    runtimeStates,
    upstreamMap,
    simulationTime,
    events,
  );
  final propagated = evaluateRecoveryPropagation(
    runtimeStates,
    upstreamMap,
    simulationTime,
    events,
  );

  return started || progressed || promoted || propagated;
}

bool allServicesHealthy(Map<String, ServiceRuntime> runtimeStates) {
  return runtimeStates.values.every((runtime) => runtime.state == 'HEALTHY');
}

class RecoverySimulationResult {
  final List<SimulationEvent> events;
  final List<SimulationSnapshot> snapshots;
  final Map<String, String> finalStates;
  final int recoveryTime;
  final int completedAt;

  const RecoverySimulationResult({
    required this.events,
    required this.snapshots,
    required this.finalStates,
    required this.recoveryTime,
    required this.completedAt,
  });
}

RecoverySimulationResult runRecoverySimulation({
  required Map<String, ServiceRuntime> initialStates,
  required List<DependencyModel> dependencies,
  required List<RecoveryAction> recoveryActions,
  required Map<String, int> recoveryDurations,
  required SimulationConfig config,
  required int startTime,
  required int firstDisruptionTime,
}) {
  if (recoveryActions.isEmpty) {
    throw Exception('Select at least one service to recover.');
  }

  final runtimeStates = <String, ServiceRuntime>{};
  for (final entry in initialStates.entries) {
    runtimeStates[entry.key] = entry.value.clone();
  }

  final upstreamMap = buildUpstreamMap(dependencies);
  final events = <SimulationEvent>[];
  final snapshots = [snapshotFromRuntime(startTime, runtimeStates)];

  int stableTicks = 0;
  int simulationTime = startTime;
  int? recoveryCompleteTime;

  while (simulationTime - startTime < config.durationSeconds) {
    simulationTime += config.tickSeconds;
    final changed = processRecoveryTick(
      runtimeStates,
      upstreamMap,
      recoveryActions,
      recoveryDurations,
      simulationTime,
      events,
    );

    snapshots.add(snapshotFromRuntime(simulationTime, runtimeStates));

    if (allServicesHealthy(runtimeStates)) {
      recoveryCompleteTime ??= simulationTime;
      stableTicks += 1;
      if (stableTicks >= 3) {
        events.add(SimulationEvent(
          simulationTime: simulationTime,
          serviceId: recoveryActions[0].serviceId,
          eventType: 'STABILIZED',
          reason: 'System stabilized after recovery',
        ));
        break;
      }
      continue;
    }

    recoveryCompleteTime = null;
    stableTicks = changed ? 0 : stableTicks + 1;
    if (stableTicks >= 3) break;
  }

  final finalRecoveryTime =
      recoveryCompleteTime != null ? recoveryCompleteTime - firstDisruptionTime : 0;

  final finalStates = <String, String>{};
  for (final entry in runtimeStates.entries) {
    finalStates[entry.key] = entry.value.state;
  }

  return RecoverySimulationResult(
    events: events,
    snapshots: snapshots,
    finalStates: finalStates,
    recoveryTime: finalRecoveryTime,
    completedAt: simulationTime,
  );
}
