import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/simulation_controller.dart';
import '../../widgets/metrics/metric_cards_grid.dart';
import '../../widgets/metrics/simulation_progress_bar.dart';
import '../../widgets/timeline/simulation_timeline_widget.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimulationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CASCADE ANALYTICS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Metrics & Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 14),

          // 4 Core Metrics Grid
          MetricCardsGrid(
            metrics: controller.metrics,
            phase: controller.phase,
          ),

          const SizedBox(height: 16),

          // Simulation Progress Bar
          SimulationProgressBar(
            simulationTime: controller.simulationTime,
            totalDuration: controller.totalDuration,
            phase: controller.phase,
            status: controller.status,
          ),

          const SizedBox(height: 16),

          // Interactive Timeline & Live Event Stream
          const SimulationTimelineWidget(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
