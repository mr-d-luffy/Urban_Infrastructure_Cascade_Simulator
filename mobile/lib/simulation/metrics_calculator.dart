import 'dart:math' as math;
import '../models/dependency_model.dart';
import '../models/service_model.dart';
import '../models/simulation_event.dart';
import '../models/simulation_metrics.dart';
import 'recovery_engine.dart';
import 'simulation_types.dart';

const int criticalityThreshold = 4;
const Set<String> impactEventTypes = {'FAILURE', 'DEGRADATION', 'PROPAGATION'};

Set<String> affectedServiceIdsFromEvents(List<SimulationEvent> events) {
  final ids = <String>{};
  for (final event in events) {
    if (impactEventTypes.contains(event.eventType)) {
      ids.add(event.serviceId);
    }
  }
  return ids;
}

int countCriticalAffected(List<ServiceModel> services, Set<String> affectedIds) {
  return services
      .where((s) => s.criticality >= criticalityThreshold && affectedIds.contains(s.id))
      .length;
}

int computeCascadeDepthFromRoots(
  List<String> roots,
  List<DependencyModel> dependencies,
  List<String> affectedServiceIds,
) {
  if (affectedServiceIds.isEmpty) return 0;

  final downstream = buildDownstreamMap(dependencies);
  final depths = <String, int>{};
  final queue = <MapEntry<String, int>>[];

  for (final root in roots) {
    depths[root] = 0;
    queue.add(MapEntry(root, 0));
  }

  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    final neighbors = downstream[current.key] ?? [];

    for (final neighbor in neighbors) {
      final nextDepth = current.value + 1;
      final existing = depths[neighbor];
      if (existing == null || nextDepth < existing) {
        depths[neighbor] = nextDepth;
        queue.add(MapEntry(neighbor, nextDepth));
      }
    }
  }

  int maxDepth = 0;
  for (final serviceId in affectedServiceIds) {
    final depth = depths[serviceId] ?? 0;
    maxDepth = math.max(maxDepth, depth);
  }

  return maxDepth;
}

SimulationMetrics calculateMetrics(SimulationResult result, List<ServiceModel> services) {
  final affectedIds = affectedServiceIdsFromEvents(result.events);
  final totalServices = services.length;
  final affectedServices = math.max(result.affectedServices, affectedIds.length);
  final impactPercentage = totalServices == 0
      ? 0.0
      : double.parse(((affectedServices / totalServices) * 100).toStringAsFixed(1));

  return SimulationMetrics(
    affectedServices: affectedServices,
    cascadeDepth: result.cascadeDepth,
    recoveryTime: result.recoveryTime,
    impactPercentage: impactPercentage,
    criticalServicesAffected: countCriticalAffected(services, affectedIds),
    totalServices: totalServices,
  );
}

SimulationMetrics mergeRecoveryMetrics(
  SimulationMetrics base,
  RecoverySimulationResult recovery,
) {
  return base.copyWith(
    recoveryTime: recovery.recoveryTime,
  );
}

SimulationMetrics? computeDisplayMetrics(
  SimulationMetrics? base,
  List<ServiceModel> services,
  List<SimulationEvent> events,
  String phase,
) {
  if (base == null) return null;
  if (phase == 'complete') return base;

  final currentlyImpacted = services
      .where((s) => s.state == 'DEGRADED' || s.state == 'FAILED' || s.state == 'RECOVERING')
      .length;

  final affectedIds = affectedServiceIdsFromEvents(events);
  final affectedCount = math.max(base.affectedServices, math.max(currentlyImpacted, affectedIds.length));
  final criticalCount = math.max(base.criticalServicesAffected, countCriticalAffected(services, affectedIds));
  final impact = base.totalServices == 0
      ? 0.0
      : double.parse(((affectedCount / base.totalServices) * 100).toStringAsFixed(1));

  return base.copyWith(
    affectedServices: affectedCount,
    criticalServicesAffected: criticalCount,
    impactPercentage: impact,
  );
}

String formatRecoveryTime(int seconds) {
  if (seconds <= 0) return '—';
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  if (minutes == 0) return '${remaining}s';
  return '${minutes}m ${remaining.toString().padLeft(2, '0')}s';
}

String formatMetricValue(int value) {
  return value.toString().padLeft(2, '0');
}

Map<String, int> buildRecoveryDurations(List<ServiceModel> services) {
  final map = <String, int>{};
  for (final s in services) {
    map[s.id] = math.max(4, math.min(10, s.criticality + 1));
  }
  return map;
}
