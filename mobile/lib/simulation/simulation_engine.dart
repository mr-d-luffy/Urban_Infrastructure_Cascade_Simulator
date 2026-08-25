import 'dart:math' as math;
import '../models/dependency_model.dart';
import '../models/scenario_model.dart';
import '../models/simulation_event.dart';
import 'metrics_calculator.dart';
import 'propagation_engine.dart';
import 'simulation_types.dart';

const int stableTicksRequired = 3;

SimulationResult runSimulation({
  required List<String> serviceIds,
  required List<DependencyModel> dependencies,
  required List<DisruptionModel> disruptions,
  required SimulationConfig config,
}) {
  if (disruptions.isEmpty) {
    throw Exception('At least one disruption is required to run a simulation.');
  }

  final runtimeStates = createRuntimeStates(serviceIds);
  final upstreamMap = buildUpstreamMap(dependencies);
  final events = <SimulationEvent>[];
  final snapshots = [snapshotFromRuntime(0, runtimeStates)];

  int stableTicks = 0;
  int simulationTime = 0;

  while (simulationTime < config.durationSeconds) {
    simulationTime += config.tickSeconds;
    final changed = processSimulationTick(
      runtimeStates,
      upstreamMap,
      disruptions,
      simulationTime,
      events,
    );

    snapshots.add(snapshotFromRuntime(simulationTime, runtimeStates));

    if (changed) {
      stableTicks = 0;
    } else {
      stableTicks += 1;
    }

    if (stableTicks >= stableTicksRequired) {
      events.add(SimulationEvent(
        simulationTime: simulationTime,
        serviceId: disruptions.first.serviceId,
        eventType: 'STABILIZED',
        reason: 'No further state transitions detected',
      ));
      break;
    }
  }

  final affectedServices = runtimeStates.values.where(
    (runtime) =>
        runtime.firstAffectedTime != null &&
        (runtime.state == 'DEGRADED' || runtime.state == 'FAILED'),
  ).toList();

  final cascadeDepth = computeCascadeDepthFromRoots(
    disruptions.map((d) => d.serviceId).toList(),
    dependencies,
    affectedServices.map((r) => r.id).toList(),
  );

  final finalStates = <String, String>{};
  for (final entry in runtimeStates.entries) {
    finalStates[entry.key] = entry.value.state;
  }

  final firstDisruptionTime = disruptions.map((d) => d.startTime).reduce(math.min);

  return SimulationResult(
    events: events,
    snapshots: snapshots,
    finalStates: finalStates,
    runtimeStates: runtimeStates,
    affectedServices: affectedServices.length,
    cascadeDepth: cascadeDepth,
    recoveryTime: 0,
    completedAt: simulationTime,
    firstDisruptionTime: firstDisruptionTime,
  );
}

ScenarioModel createPowerGridFailureScenario({String serviceId = 'svc-power'}) {
  return ScenarioModel(
    id: 'demo-power-grid',
    name: 'Power Grid Failure Demo',
    description: 'Critical failure at power grid propagating to dependent municipal services',
    seed: 42003,
    durationSeconds: 60,
    tickSeconds: 1,
    disruptions: [
      DisruptionModel(serviceId: serviceId, startTime: 0, severity: 1.0),
    ],
  );
}
