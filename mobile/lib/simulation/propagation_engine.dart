import 'dart:math' as math;
import '../models/dependency_model.dart';
import '../models/scenario_model.dart';
import '../models/simulation_event.dart';
import 'simulation_types.dart';

const double degradedThreshold = 0.5;
const double failedThreshold = 1.0;

double upstreamStressContribution(String state, double strength) {
  switch (state) {
    case 'FAILED':
      return strength;
    case 'DEGRADED':
      return strength * 0.5;
    case 'RECOVERING':
      return strength * 0.25;
    case 'RECOVERED':
    case 'HEALTHY':
    default:
      return 0.0;
  }
}

List<DisruptionModel> getActiveDisruptions(List<DisruptionModel> disruptions, int simulationTime) {
  return disruptions.where((disruption) {
    if (disruption.startTime > simulationTime) return false;
    if (disruption.duration == null) return true;
    return simulationTime < disruption.startTime + disruption.duration!;
  }).toList();
}

bool applyDisruptions(
  Map<String, ServiceRuntime> runtimeStates,
  List<DisruptionModel> disruptions,
  int simulationTime,
  List<SimulationEvent> events,
) {
  bool changed = false;
  final active = getActiveDisruptions(disruptions, simulationTime);

  for (final disruption in active) {
    final runtime = runtimeStates[disruption.serviceId];
    if (runtime == null) continue;

    runtime.disrupted = true;

    if (disruption.severity >= failedThreshold && runtime.state != 'FAILED') {
      final previousState = runtime.state;
      runtime.state = 'FAILED';
      runtime.stress = 1.0;
      runtime.recoveryTicksRemaining = null;
      markAffected(runtime, simulationTime, 'FAILED');
      events.add(SimulationEvent(
        simulationTime: simulationTime,
        serviceId: runtime.id,
        eventType: 'FAILURE',
        previousState: previousState,
        newState: 'FAILED',
        reason: 'Initial disruption applied',
      ));
      changed = true;
    } else if (disruption.severity >= degradedThreshold && runtime.state == 'HEALTHY') {
      runtime.state = 'DEGRADED';
      runtime.stress = disruption.severity;
      markAffected(runtime, simulationTime, 'DEGRADED');
      events.add(SimulationEvent(
        simulationTime: simulationTime,
        serviceId: runtime.id,
        eventType: 'DEGRADATION',
        previousState: 'HEALTHY',
        newState: 'DEGRADED',
        reason: 'Partial disruption applied',
      ));
      changed = true;
    }
  }

  return changed;
}

bool evaluateDependencyPropagation(
  Map<String, ServiceRuntime> runtimeStates,
  Map<String, List<DependencyModel>> upstreamMap,
  int simulationTime,
  List<SimulationEvent> events, {
  bool allowDeescalation = false,
}) {
  bool changed = false;

  for (final runtime in runtimeStates.values) {
    if (runtime.state == 'RECOVERING' || runtime.state == 'RECOVERED') continue;
    if (runtime.state == 'FAILED' && runtime.disrupted && !allowDeescalation) continue;

    final upstream = upstreamMap[runtime.id] ?? [];
    double stress = 0.0;

    for (final dep in upstream) {
      final upstreamRuntime = runtimeStates[dep.sourceServiceId];
      if (upstreamRuntime == null) continue;
      stress += upstreamStressContribution(upstreamRuntime.state, dep.dependencyStrength);
    }

    runtime.stress = math.min(stress, 1.5);

    final previousState = runtime.state;
    String nextState = previousState;

    if (stress >= failedThreshold && previousState != 'FAILED') {
      nextState = 'FAILED';
    } else if (stress >= degradedThreshold && previousState == 'HEALTHY') {
      nextState = 'DEGRADED';
    } else if (stress >= failedThreshold && previousState == 'DEGRADED' && !runtime.disrupted) {
      nextState = 'FAILED';
    } else if (allowDeescalation) {
      if (previousState == 'FAILED' && !runtime.disrupted && stress < degradedThreshold) {
        nextState = stress >= degradedThreshold ? 'DEGRADED' : 'HEALTHY';
      } else if (previousState == 'DEGRADED' && stress < degradedThreshold) {
        nextState = 'HEALTHY';
      } else if (previousState == 'FAILED' &&
          !runtime.disrupted &&
          stress >= degradedThreshold &&
          stress < failedThreshold) {
        nextState = 'DEGRADED';
      }
    }

    if (nextState != previousState) {
      runtime.state = nextState;
      if (nextState == 'HEALTHY') {
        runtime.stress = 0.0;
      }
      markAffected(runtime, simulationTime, nextState);
      events.add(SimulationEvent(
        simulationTime: simulationTime,
        serviceId: runtime.id,
        eventType: eventTypeForTransition(previousState, nextState),
        previousState: previousState,
        newState: nextState,
        reason: allowDeescalation
            ? 'Dependency stress reduced during recovery'
            : 'Upstream dependency failure propagation',
      ));
      changed = true;
    }
  }

  return changed;
}

bool processSimulationTick(
  Map<String, ServiceRuntime> runtimeStates,
  Map<String, List<DependencyModel>> upstreamMap,
  List<DisruptionModel> disruptions,
  int simulationTime,
  List<SimulationEvent> events,
) {
  final disruptionChanged = applyDisruptions(
    runtimeStates,
    disruptions,
    simulationTime,
    events,
  );
  final propagationChanged = evaluateDependencyPropagation(
    runtimeStates,
    upstreamMap,
    simulationTime,
    events,
  );
  return disruptionChanged || propagationChanged;
}
