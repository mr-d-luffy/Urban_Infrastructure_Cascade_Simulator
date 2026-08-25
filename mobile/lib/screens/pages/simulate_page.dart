import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/simulation_controller.dart';
import '../../widgets/simulation/disruption_picker.dart';
import '../../widgets/simulation/recovery_picker.dart';
import '../../widgets/simulation/scenario_manager_card.dart';
import '../../widgets/simulation/simulation_controls_view.dart';

class SimulatePage extends StatelessWidget {
  const SimulatePage({super.key});

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
            'SIMULATOR CONFIGURATION',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Disruptions & Recovery',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 14),

          // Primary Simulation Action Controls
          const SimulationControlsView(),

          const SizedBox(height: 16),

          // Service Disruption / Recovery Targets Selection
          if (controller.phase == 'idle')
            const DisruptionPicker()
          else
            const RecoveryPicker(),

          const SizedBox(height: 16),

          // Scenario Manager Card
          const ScenarioManagerCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
