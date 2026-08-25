import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/dependency_model.dart';
import '../../models/service_model.dart';

class GraphPainter extends CustomPainter {
  final List<ServiceModel> services;
  final List<DependencyModel> dependencies;
  final String? selectedId;
  final List<String> activeEdgeIds;
  final bool isDark;
  final double pulseProgress;

  GraphPainter({
    required this.services,
    required this.dependencies,
    this.selectedId,
    required this.activeEdgeIds,
    required this.isDark,
    this.pulseProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle grid dots
    final dotPaint = Paint()
      ..color = (isDark ? AppTheme.darkGridDots : AppTheme.lightGridDots).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    const double dotSpacing = 24.0;
    for (double x = 0; x < size.width; x += dotSpacing) {
      for (double y = 0; y < size.height; y += dotSpacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }

    final serviceMap = {for (final s in services) s.id: s};

    // Draw directed dependency edges
    for (final dep in dependencies) {
      final src = serviceMap[dep.sourceServiceId];
      final dst = serviceMap[dep.targetServiceId];
      if (src == null || dst == null) continue;

      final bool isActive = activeEdgeIds.contains(dep.id);
      final Color edgeColor = isActive ? AppTheme.critical : AppTheme.neutral.withValues(alpha: isDark ? 0.45 : 0.4);
      final double strokeWidth = isActive ? 2.5 : 1.5;

      final p1 = src.position + const Offset(70, 30); // Center of source node
      final p2 = dst.position + const Offset(70, 30); // Center of target node

      final edgePaint = Paint()
        ..color = edgeColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      // Draw smooth curve between nodes
      final path = Path();
      path.moveTo(p1.dx, p1.dy);

      final controlPoint1 = Offset(p1.dx, p1.dy + (p2.dy - p1.dy) * 0.5);
      final controlPoint2 = Offset(p2.dx, p1.dy + (p2.dy - p1.dy) * 0.5);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);

      canvas.drawPath(path, edgePaint);

      // Draw arrowhead at target
      final angle = math.atan2(p2.dy - controlPoint2.dy, p2.dx - controlPoint2.dx);
      const arrowSize = 7.0;
      final arrowPath = Path()
        ..moveTo(
          p2.dx - 22 * math.cos(angle),
          p2.dy - 22 * math.sin(angle),
        )
        ..lineTo(
          p2.dx - 22 * math.cos(angle) - arrowSize * math.cos(angle - math.pi / 6),
          p2.dy - 22 * math.sin(angle) - arrowSize * math.sin(angle - math.pi / 6),
        )
        ..lineTo(
          p2.dx - 22 * math.cos(angle) - arrowSize * math.cos(angle + math.pi / 6),
          p2.dy - 22 * math.sin(angle) - arrowSize * math.sin(angle + math.pi / 6),
        )
        ..close();

      final arrowPaint = Paint()
        ..color = edgeColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(arrowPath, arrowPaint);

      // Animated cascade pulse traveling down active edge
      if (isActive) {
        final t = (pulseProgress * 2.0) % 1.0;
        final pulsePoint = Offset(
          p1.dx + (p2.dx - p1.dx) * t,
          p1.dy + (p2.dy - p1.dy) * t,
        );
        final pulsePaint = Paint()
          ..color = AppTheme.critical
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pulsePoint, 4.0, pulsePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.services != services ||
        oldDelegate.dependencies != dependencies ||
        oldDelegate.selectedId != selectedId ||
        oldDelegate.activeEdgeIds != activeEdgeIds ||
        oldDelegate.isDark != isDark ||
        oldDelegate.pulseProgress != pulseProgress;
  }
}
