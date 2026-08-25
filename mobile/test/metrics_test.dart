import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/simulation/metrics_calculator.dart';
import 'package:mobile/simulation/seed_data.dart';
import 'package:mobile/simulation/simulation_engine.dart';
import 'package:mobile/simulation/simulation_types.dart';

void main() {
  group('Metrics Calculator Tests', () {
    test('formatRecoveryTime formats seconds into readable mm:ss format', () {
      expect(formatRecoveryTime(0), equals('—'));
      expect(formatRecoveryTime(42), equals('42s'));
      expect(formatRecoveryTime(95), equals('1m 35s'));
      expect(formatRecoveryTime(1112), equals('18m 32s'));
    });

    test('calculateMetrics derives accurate impact percentages and critical counts', () {
      final scenario = createPowerGridFailureScenario(serviceId: 'svc-power');

      final result = runSimulation(
        serviceIds: seedServices.map((s) => s.id).toList(),
        dependencies: seedDependencies,
        disruptions: scenario.disruptions,
        config: const SimulationConfig(),
      );

      final metrics = calculateMetrics(result, seedServices);
      expect(metrics.totalServices, equals(8));
      expect(metrics.affectedServices, greaterThan(0));
      expect(metrics.impactPercentage, greaterThan(0.0));
      expect(metrics.criticalServicesAffected, greaterThan(0));
    });
  });
}
