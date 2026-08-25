import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/simulation_controller.dart';
import '../common/cinematic_button.dart';

class SimulationControlsView extends StatelessWidget {
  const SimulationControlsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimulationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isRunning = controller.status == 'RUNNING';
    final canRun = controller.disruptions.isNotEmpty && !isRunning && controller.phase == 'idle';
    final canRecover = controller.recoveryTargets.isNotEmpty &&
        !isRunning &&
        (controller.phase == 'failure' || controller.phase == 'complete') &&
        controller.recoverableServices.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'SIMULATION CONTROLS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'T+${controller.simulationTime}s · ${controller.phase}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.neutral.withValues(alpha: 0.9) : AppTheme.neutral,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons Wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Power Failure Demo
              CinematicButton(
                label: 'Power failure demo',
                icon: Icons.flash_on,
                style: CinematicButtonStyle.secondary,
                onPressed: isRunning ? null : () => controller.loadDemoScenario(),
              ),

              // Run Simulation
              CinematicButton(
                label: isRunning && controller.phase == 'failure' ? 'Running…' : 'Run simulation',
                icon: Icons.arrow_forward,
                style: CinematicButtonStyle.primary,
                isLoading: isRunning && controller.phase == 'failure',
                onPressed: canRun ? () => controller.runSimulationPlayback() : null,
              ),

              // Start Recovery
              CinematicButton(
                label: isRunning && controller.phase == 'recovery' ? 'Recovering…' : 'Start recovery',
                icon: Icons.timer_outlined,
                style: CinematicButtonStyle.success,
                isLoading: isRunning && controller.phase == 'recovery',
                onPressed: canRecover ? () => controller.runRecoveryPlayback() : null,
              ),

              // Reset
              CinematicButton(
                label: 'Reset',
                icon: Icons.refresh,
                style: CinematicButtonStyle.secondary,
                onPressed: isRunning ? null : () => controller.resetSimulation(),
              ),
            ],
          ),

          if (controller.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.critical.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.critical.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: AppTheme.critical),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      controller.error!,
                      style: const TextStyle(fontSize: 11, color: AppTheme.critical),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (controller.metrics != null) ...[
            const SizedBox(height: 12),
            Text(
              '${controller.metrics!.criticalServicesAffected > 0 ? "${controller.metrics!.criticalServicesAffected} critical services affected · " : ""}Impact ${controller.metrics!.impactPercentage}%',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
