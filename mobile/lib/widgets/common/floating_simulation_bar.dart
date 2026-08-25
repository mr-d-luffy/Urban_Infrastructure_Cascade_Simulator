import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/simulation_controller.dart';

class FloatingSimulationBar extends StatelessWidget {
  final VoidCallback onNavigateToSimulation;

  const FloatingSimulationBar({
    super.key,
    required this.onNavigateToSimulation,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimulationController>();
    if (controller.phase == 'idle' && controller.status != 'RUNNING') {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRunning = controller.status == 'RUNNING';

    Color statusColor;
    if (controller.phase == 'failure') {
      statusColor = AppTheme.critical;
    } else if (controller.phase == 'recovery') {
      statusColor = AppTheme.warning;
    } else {
      statusColor = AppTheme.success;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${controller.phase.toUpperCase()} · ${controller.status}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: statusColor,
                  ),
                ),
                Text(
                  'T+${controller.simulationTime}s · ${controller.events.length} events',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
          if (controller.recoverableServices.isNotEmpty && !isRunning && controller.phase != 'complete')
            TextButton(
              onPressed: () {
                onNavigateToSimulation();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                backgroundColor: AppTheme.success.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Recover',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.success),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, size: 16),
              color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
              onPressed: () => controller.resetSimulation(),
              tooltip: 'Reset',
            ),
        ],
      ),
    );
  }
}
