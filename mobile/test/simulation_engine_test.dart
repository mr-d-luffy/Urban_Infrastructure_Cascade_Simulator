import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/simulation/recovery_engine.dart';
import 'package:mobile/simulation/seed_data.dart';
import 'package:mobile/simulation/simulation_engine.dart';
import 'package:mobile/simulation/simulation_types.dart';

void main() {
  group('Simulation Engine Tests', () {
    test('Power Grid failure triggers cascading failures across dependent services', () {
      final scenario = createPowerGridFailureScenario(serviceId: 'svc-power');

      final result = runSimulation(
        serviceIds: seedServices.map((s) => s.id).toList(),
        dependencies: seedDependencies,
        disruptions: scenario.disruptions,
        config: const SimulationConfig(),
      );

      expect(result.events.isNotEmpty, isTrue);
      expect(result.finalStates['svc-power'], equals('FAILED'));
      expect(result.finalStates['svc-hospital'], equals('FAILED'));
      expect(result.finalStates['svc-water'], equals('FAILED'));
      expect(result.finalStates['svc-transport'], equals('FAILED'));
      expect(result.finalStates['svc-emergency'], equals('FAILED'));

      expect(result.affectedServices, greaterThanOrEqualTo(5));
      expect(result.cascadeDepth, equals(2));
    });

    test('Recovery simulation successfully restores services to healthy state', () {
      final scenario = createPowerGridFailureScenario(serviceId: 'svc-power');

      final simResult = runSimulation(
        serviceIds: seedServices.map((s) => s.id).toList(),
        dependencies: seedDependencies,
        disruptions: scenario.disruptions,
        config: const SimulationConfig(),
      );

      final recoveryActions = [
        const RecoveryAction(serviceId: 'svc-power', startTime: 10),
      ];

      final recoveryDurations = {
        for (final s in seedServices) s.id: 4,
      };

      final recoveryResult = runRecoverySimulation(
        initialStates: simResult.runtimeStates,
        dependencies: seedDependencies,
        recoveryActions: recoveryActions,
        recoveryDurations: recoveryDurations,
        config: const SimulationConfig(durationSeconds: 90),
        startTime: 9,
        firstDisruptionTime: 0,
      );

      expect(recoveryResult.events.isNotEmpty, isTrue);
      expect(recoveryResult.finalStates['svc-power'], equals('HEALTHY'));
      expect(recoveryResult.recoveryTime, greaterThan(0));
    });
  });
}
