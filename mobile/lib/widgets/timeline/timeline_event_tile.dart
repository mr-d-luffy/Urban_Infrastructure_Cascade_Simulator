import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/simulation_event.dart';

class TimelineEventTile extends StatelessWidget {
  final SimulationEvent event;
  final String serviceName;

  const TimelineEventTile({
    super.key,
    required this.event,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stateColor = event.newState != null ? AppTheme.stateColor(event.newState!) : AppTheme.neutral;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: stateColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    Text(
                      serviceName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                      ),
                    ),
                    Text(
                      '· ${event.friendlyEventType}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                      ),
                    ),
                    if (event.previousState != null && event.newState != null)
                      Text(
                        '(${event.previousState} → ${event.newState})',
                        style: TextStyle(
                          fontSize: 9,
                          fontFamily: 'monospace',
                          color: stateColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                if (event.reason != null && event.reason!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.reason!,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? AppTheme.neutral.withValues(alpha: 0.7) : AppTheme.neutral,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'T+${event.simulationTime}s',
            style: TextStyle(
              fontSize: 10,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
            ),
          ),
        ],
      ),
    );
  }
}
