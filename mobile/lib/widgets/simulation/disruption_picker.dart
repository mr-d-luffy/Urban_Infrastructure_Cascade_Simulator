import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/simulation_controller.dart';

class DisruptionPicker extends StatelessWidget {
  const DisruptionPicker({super.key});

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
                'DISRUPTIONS',
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
                  color: (controller.disruptions.isNotEmpty ? AppTheme.critical : AppTheme.neutral)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${controller.disruptions.length} SELECTED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: controller.disruptions.isNotEmpty ? AppTheme.critical : AppTheme.neutral,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'Select services to fail at T+0. Multiple simultaneous disruptions are supported.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
            ),
          ),

          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.services.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final service = controller.services[index];
              final isDisrupted = controller.disruptions.any((d) => d.serviceId == service.id);
              final isFocused = controller.selectedId == service.id;

              return InkWell(
                onTap: isRunning ? null : () => controller.toggleDisruption(service.id),
                borderRadius: BorderRadius.circular(6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDisrupted
                        ? AppTheme.critical.withValues(alpha: isDark ? 0.2 : 0.08)
                        : (isFocused
                            ? (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.06)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDisrupted
                          ? AppTheme.critical.withValues(alpha: 0.6)
                          : (isFocused
                              ? (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.3)
                              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)),
                      width: isDisrupted ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppTheme.categoryIcon(service.category),
                        size: 16,
                        color: isDisrupted
                            ? AppTheme.critical
                            : (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          service.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isDisrupted ? FontWeight.w600 : FontWeight.w500,
                            color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                      Icon(
                        isDisrupted ? Icons.bolt : Icons.radio_button_unchecked,
                        size: 16,
                        color: isDisrupted ? AppTheme.critical : AppTheme.neutral.withValues(alpha: 0.5),
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
