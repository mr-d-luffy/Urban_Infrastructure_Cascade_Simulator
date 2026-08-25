import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class SimulationProgressBar extends StatelessWidget {
  final int simulationTime;
  final int totalDuration;
  final String phase;
  final String status;

  const SimulationProgressBar({
    super.key,
    required this.simulationTime,
    required this.totalDuration,
    required this.phase,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = totalDuration > 0
        ? (simulationTime / totalDuration).clamp(0.0, 1.0)
        : (status == 'RUNNING' ? null : 0.0);

    Color phaseColor;
    switch (phase) {
      case 'failure':
        phaseColor = AppTheme.critical;
        break;
      case 'recovery':
        phaseColor = AppTheme.warning;
        break;
      case 'complete':
        phaseColor = AppTheme.success;
        break;
      case 'idle':
      default:
        phaseColor = AppTheme.neutral;
    }

    return Container(
      padding: const EdgeInsets.all(14),
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
                'SIMULATION PROGRESS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: phaseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${phase.toUpperCase()} · ${status.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: phaseColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'T+${simulationTime}s',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                ),
              ),
              if (totalDuration > 0)
                Text(
                  'Total duration: ${totalDuration}s',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
