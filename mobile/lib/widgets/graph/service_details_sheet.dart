import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/service_model.dart';
import '../../providers/simulation_controller.dart';
import '../common/cinematic_button.dart';
import '../common/status_badge.dart';

class ServiceDetailsSheet extends StatelessWidget {
  final ServiceModel service;
  final List<ServiceModel> upstream;
  final List<ServiceModel> downstream;
  final ValueChanged<String> onSelectService;

  const ServiceDetailsSheet({
    super.key,
    required this.service,
    required this.upstream,
    required this.downstream,
    required this.onSelectService,
  });

  static void show(
    BuildContext context, {
    required ServiceModel service,
    required List<ServiceModel> upstream,
    required List<ServiceModel> downstream,
    required ValueChanged<String> onSelectService,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ServiceDetailsSheet(
        service: service,
        upstream: upstream,
        downstream: downstream,
        onSelectService: onSelectService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<SimulationController>();
    final isDisrupted = controller.disruptions.any((d) => d.serviceId == service.id);
    final isRecoveryTarget = controller.recoveryTargets.contains(service.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      AppTheme.categoryIcon(service.category),
                      size: 24,
                      color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SERVICE DETAILS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          service.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.forState(service.state, fontSize: 11),
                ],
              ),

              const SizedBox(height: 16),

              // Criticality & Category tags
              Row(
                children: [
                  Expanded(child: _infoChip('CATEGORY', service.category, isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _infoChip('CRITICALITY', '${service.criticality} / 5', isDark)),
                ],
              ),

              if (service.description != null && service.description!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.description!,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? AppTheme.neutral.withValues(alpha: 0.9) : AppTheme.neutral,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Upstream Dependencies
              _dependencySection(
                title: 'DEPENDS ON (UPSTREAM)',
                items: upstream,
                emptyText: 'No upstream dependencies',
                isDark: isDark,
                onTap: (id) {
                  Navigator.of(context).pop();
                  onSelectService(id);
                },
              ),

              const SizedBox(height: 14),

              // Downstream Dependents
              _dependencySection(
                title: 'DEPENDENTS (DOWNSTREAM)',
                items: downstream,
                emptyText: 'No downstream dependents',
                isDark: isDark,
                onTap: (id) {
                  Navigator.of(context).pop();
                  onSelectService(id);
                },
              ),

              const SizedBox(height: 20),

              // Quick Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CinematicButton(
                      label: isDisrupted ? 'Remove Disruption' : 'Disrupt Service',
                      icon: isDisrupted ? Icons.close : Icons.bolt,
                      style: isDisrupted ? CinematicButtonStyle.danger : CinematicButtonStyle.secondary,
                      onPressed: controller.status == 'RUNNING'
                          ? null
                          : () {
                              controller.toggleDisruption(service.id);
                            },
                    ),
                  ),
                  if (service.state == 'FAILED' || service.state == 'DEGRADED') ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: CinematicButton(
                        label: isRecoveryTarget ? 'Targeted' : 'Recover',
                        icon: Icons.timer_outlined,
                        style: CinematicButtonStyle.success,
                        onPressed: controller.status == 'RUNNING'
                            ? null
                            : () {
                                controller.toggleRecoveryTarget(service.id);
                              },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String title, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dependencySection({
    required String title,
    required List<ServiceModel> items,
    required String emptyText,
    required bool isDark,
    required ValueChanged<String> onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
          ),
        ),
        const SizedBox(height: 6),
        if (items.isEmpty)
          Text(
            emptyText,
            style: TextStyle(fontSize: 11, color: isDark ? AppTheme.neutral.withValues(alpha: 0.7) : AppTheme.neutral),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: items.map((item) {
              return ActionChip(
                backgroundColor: (isDark ? AppTheme.darkSurface : AppTheme.lightSurface),
                side: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                avatar: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.stateColor(item.state),
                    shape: BoxShape.circle,
                  ),
                ),
                label: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                  ),
                ),
                onPressed: () => onTap(item.id),
              );
            }).toList(),
          ),
      ],
    );
  }
}
