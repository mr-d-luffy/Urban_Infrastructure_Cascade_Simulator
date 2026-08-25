import 'package:flutter/material.dart';
import '../../models/simulation_metrics.dart';
import '../../simulation/metrics_calculator.dart';
import 'metric_card.dart';

class MetricCardsGrid extends StatelessWidget {
  final SimulationMetrics? metrics;
  final String phase;

  const MetricCardsGrid({
    super.key,
    required this.metrics,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    if (metrics == null) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.38,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          MetricCard(label: 'Affected Services', value: '—', icon: Icons.lan_outlined),
          MetricCard(label: 'Cascade Depth', value: '—', icon: Icons.alt_route_outlined),
          MetricCard(label: 'Recovery Time', value: '—', icon: Icons.timer_outlined),
          MetricCard(label: 'System Impact', value: '—', icon: Icons.pie_chart_outline),
        ],
      );
    }

    final recoveryValue = metrics!.recoveryTime > 0
        ? formatRecoveryTime(metrics!.recoveryTime)
        : '—';

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.38,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        MetricCard(
          label: 'Affected Services',
          value: formatMetricValue(metrics!.affectedServices),
          hint: metrics!.criticalServicesAffected > 0
              ? '${metrics!.criticalServicesAffected} critical'
              : '${metrics!.totalServices} total',
          icon: Icons.lan_outlined,
        ),
        MetricCard(
          label: 'Cascade Depth',
          value: formatMetricValue(metrics!.cascadeDepth),
          hint: 'Max propagation depth',
          icon: Icons.alt_route_outlined,
        ),
        MetricCard(
          label: 'Recovery Time',
          value: recoveryValue,
          hint: phase == 'complete' ? 'Stabilized' : 'Active simulation',
          icon: Icons.timer_outlined,
        ),
        MetricCard(
          label: 'System Impact',
          value: '${metrics!.impactPercentage}%',
          hint: '${metrics!.totalServices} total services',
          icon: Icons.pie_chart_outline,
        ),
      ],
    );
  }
}
