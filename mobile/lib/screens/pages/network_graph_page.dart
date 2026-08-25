import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/simulation_controller.dart';
import '../../widgets/graph/interactive_graph_view.dart';

class NetworkGraphPage extends StatelessWidget {
  final VoidCallback onNavigateToSimulate;

  const NetworkGraphPage({
    super.key,
    required this.onNavigateToSimulate,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimulationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final healthyCount = controller.services.where((s) => s.state == 'HEALTHY').length;
    final failedCount = controller.services.where((s) => s.state == 'FAILED').length;
    final recoveringCount = controller.services.where((s) => s.state == 'RECOVERING').length;

    return Column(
      children: [
        // Top Network Status Header (flex-safe)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOPOLOGY GRAPH',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Infrastructure Network',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkSurface : AppTheme.lightSurface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ),
                child: Text(
                  '$healthyCount H · $failedCount F · $recoveringCount R',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Interactive Graph View Canvas
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: InteractiveGraphView(),
          ),
        ),

        const SizedBox(height: 8),

        // Wrap Legend bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildLegendBar(isDark),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildLegendBar(bool isDark) {
    final legendItems = [
      {'label': 'HEALTHY', 'color': AppTheme.success},
      {'label': 'DEGRADED', 'color': AppTheme.degraded},
      {'label': 'FAILED', 'color': AppTheme.critical},
      {'label': 'RECOVERING', 'color': AppTheme.warning},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 12,
        runSpacing: 4,
        children: legendItems.map((item) {
          final color = item['color'] as Color;
          final label = item['label'] as String;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
