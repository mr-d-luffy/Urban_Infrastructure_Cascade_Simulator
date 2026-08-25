import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/simulation_event.dart';
import '../../providers/simulation_controller.dart';
import 'timeline_event_tile.dart';

class TimelineMarkerData {
  final String id;
  final String label;
  final int? time;

  const TimelineMarkerData({
    required this.id,
    required this.label,
    this.time,
  });
}

class SimulationTimelineWidget extends StatefulWidget {
  const SimulationTimelineWidget({super.key});

  @override
  State<SimulationTimelineWidget> createState() => _SimulationTimelineWidgetState();
}

class _SimulationTimelineWidgetState extends State<SimulationTimelineWidget> {
  String? _inspectedMarkerId;

  List<TimelineMarkerData> _deriveMarkers(List<SimulationEvent> events) {
    int? failureTime;
    int? propTime;
    int? recoveryTime;
    int? stableTime;

    for (final e in events) {
      if (e.eventType == 'FAILURE' && failureTime == null) {
        failureTime = e.simulationTime;
      } else if ((e.eventType == 'PROPAGATION' || e.eventType == 'DEGRADATION') && propTime == null) {
        propTime = e.simulationTime;
      } else if ((e.eventType == 'RECOVERY_STARTED' || e.eventType == 'RECOVERY_COMPLETED') && recoveryTime == null) {
        recoveryTime = e.simulationTime;
      } else if (e.eventType == 'STABILIZED') {
        stableTime = e.simulationTime;
      }
    }

    return [
      TimelineMarkerData(id: 'failure', label: 'FAILURE', time: failureTime),
      TimelineMarkerData(id: 'propagation', label: 'PROPAGATION', time: propTime),
      TimelineMarkerData(id: 'recovery', label: 'RECOVERY', time: recoveryTime),
      TimelineMarkerData(id: 'stable', label: 'STABLE', time: stableTime),
    ];
  }

  List<SimulationEvent> _eventsForMarker(String markerId, List<SimulationEvent> events) {
    switch (markerId) {
      case 'failure':
        return events.where((e) => e.eventType == 'FAILURE').toList();
      case 'propagation':
        return events.where((e) => e.eventType == 'PROPAGATION' || e.eventType == 'DEGRADATION').toList();
      case 'recovery':
        return events.where((e) => e.eventType == 'RECOVERY_STARTED' || e.eventType == 'RECOVERY_COMPLETED').toList();
      case 'stable':
        return events.where((e) => e.eventType == 'STABILIZED').toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimulationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final markers = _deriveMarkers(controller.events);
    final serviceNameMap = {for (final s in controller.services) s.id: s.name};

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
                'SIMULATION TIMELINE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                ),
              ),
              Text(
                'T+${controller.simulationTime}s',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (controller.events.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Run a simulation to see failure, propagation, recovery, and stabilization phases.',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                ),
              ),
            ),
          ] else ...[
            // Horizontal Step Markers Track
            Stack(
              alignment: Alignment.center,
              children: [
                // Track Line
                Container(
                  height: 1,
                  color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.15),
                ),

                // Marker Points
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: markers.map((marker) {
                    final hasTime = marker.time != null;
                    final isInspected = _inspectedMarkerId == marker.id;

                    Color dotColor;
                    if (isInspected) {
                      dotColor = isDark ? AppTheme.pureWhite : AppTheme.primaryNavy;
                    } else if (hasTime) {
                      dotColor = AppTheme.warning;
                    } else {
                      dotColor = AppTheme.neutral.withValues(alpha: 0.3);
                    }

                    return InkWell(
                      onTap: hasTime
                          ? () {
                              setState(() {
                                _inspectedMarkerId = isInspected ? null : marker.id;
                              });
                            }
                          : null,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              marker.label,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy)
                                    .withValues(alpha: hasTime ? 0.9 : 0.4),
                              ),
                            ),
                            Text(
                              hasTime ? 'T+${marker.time}s' : '—',
                              style: TextStyle(
                                fontSize: 8,
                                color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // Inspected Phase Details Box
            if (_inspectedMarkerId != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'INSPECT: ${_inspectedMarkerId!.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _inspectedMarkerId = null),
                          child: const Icon(Icons.close, size: 12, color: AppTheme.neutral),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._eventsForMarker(_inspectedMarkerId!, controller.events).map((e) {
                      final name = serviceNameMap[e.serviceId] ?? e.serviceId;
                      return TimelineEventTile(event: e, serviceName: name);
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            Divider(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder, height: 1),
            const SizedBox(height: 10),

            // Live event stream
            Text(
              'EVENT STREAM',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
              ),
            ),
            const SizedBox(height: 6),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.events.length > 8 ? 8 : controller.events.length,
              itemBuilder: (context, index) {
                // Reverse chronological
                final event = controller.events[controller.events.length - 1 - index];
                final name = serviceNameMap[event.serviceId] ?? event.serviceId;
                return TimelineEventTile(event: event, serviceName: name);
              },
            ),
          ],
        ],
      ),
    );
  }
}
