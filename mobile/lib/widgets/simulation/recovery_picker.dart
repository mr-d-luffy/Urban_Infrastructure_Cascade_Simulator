import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/simulation_controller.dart';

class RecoveryPicker extends StatelessWidget {
  const RecoveryPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimulationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRunning = controller.status == 'RUNNING';

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
              Text(
                'RECOVERY TARGETS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (controller.recoveryTargets.isNotEmpty ? AppTheme.success : AppTheme.neutral)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${controller.recoveryTargets.length} SELECTED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: controller.recoveryTargets.isNotEmpty ? AppTheme.success : AppTheme.neutral,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'Choose affected services to recover. Start with upstream services like Power Grid for cascade recovery.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
            ),
          ),

          const SizedBox(height: 12),

          if (controller.recoverableServices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No affected services remain.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recoverableServices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final service = controller.recoverableServices[index];
                final isTarget = controller.recoveryTargets.contains(service.id);

                return InkWell(
                  onTap: isRunning ? null : () => controller.toggleRecoveryTarget(service.id),
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isTarget
                          ? AppTheme.success.withValues(alpha: isDark ? 0.2 : 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isTarget
                            ? AppTheme.success.withValues(alpha: 0.6)
                            : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                        width: isTarget ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppTheme.categoryIcon(service.category),
                          size: 16,
                          color: isTarget
                              ? AppTheme.success
                              : (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  service.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isTarget ? FontWeight.w600 : FontWeight.w500,
                                    color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${service.state})',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.stateColor(service.state),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isTarget ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 16,
                          color: isTarget ? AppTheme.success : AppTheme.neutral.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
