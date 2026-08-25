import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CityBackdropPainter extends CustomPainter {
  final double animationProgress; // 0.0 to 1.0
  final bool isDark;

  CityBackdropPainter({
    required this.animationProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.3),
        radius: 0.8,
        colors: [
          isDark ? const Color(0xFF1D3045) : const Color(0xFFE2E8F0),
          isDark ? AppTheme.darkBackground : const Color(0xFFCBD5E1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw subtle skyline silhouettes
    final buildingPaint = Paint()
      ..color = (isDark ? Colors.white : AppTheme.primaryNavy).withValues(alpha: 0.08);

    final buildings = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.55, size.width * 0.12, size.height * 0.45),
      Rect.fromLTWH(size.width * 0.18, size.height * 0.45, size.width * 0.15, size.height * 0.55),
      Rect.fromLTWH(size.width * 0.35, size.height * 0.38, size.width * 0.18, size.height * 0.62),
      Rect.fromLTWH(size.width * 0.55, size.height * 0.42, size.width * 0.14, size.height * 0.58),
      Rect.fromLTWH(size.width * 0.70, size.height * 0.48, size.width * 0.16, size.height * 0.52),
      Rect.fromLTWH(size.width * 0.87, size.height * 0.58, size.width * 0.10, size.height * 0.42),
    ];

    for (final b in buildings) {
      canvas.drawRect(b, buildingPaint);
    }

    // Draw network topology nodes and lines
    final linePaint = Paint()
      ..color = (isDark ? Colors.white : AppTheme.primaryNavy).withValues(alpha: 0.18)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final pulsePaint = Paint()
      ..color = AppTheme.warning.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.85) : AppTheme.primaryNavy.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final nodes = [
      Offset(size.width * 0.5, size.height * 0.18),
      Offset(size.width * 0.25, size.height * 0.35),
      Offset(size.width * 0.75, size.height * 0.35),
      Offset(size.width * 0.38, size.height * 0.52),
      Offset(size.width * 0.62, size.height * 0.52),
      Offset(size.width * 0.5, size.height * 0.68),
    ];

    final edges = [
      [0, 1], [0, 2], [1, 3], [2, 4], [3, 5], [4, 5], [1, 4], [2, 3]
    ];

    for (final edge in edges) {
      final p1 = nodes[edge[0]];
      final p2 = nodes[edge[1]];
      canvas.drawLine(p1, p2, linePaint);

      // Animated pulse traveling along edges
      final pulsePos = Offset(
        p1.dx + (p2.dx - p1.dx) * ((animationProgress + edge[0] * 0.2) % 1.0),
        p1.dy + (p2.dy - p1.dy) * ((animationProgress + edge[0] * 0.2) % 1.0),
      );
      canvas.drawCircle(pulsePos, 2.5, pulsePaint);
    }

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      canvas.drawCircle(node, i == 0 || i == nodes.length - 1 ? 5.5 : 4.0, nodePaint);
    }

    // Cascade highlight lines across hero
    final cascadePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppTheme.warning.withValues(alpha: 0.4 * (1.0 - math.sin(animationProgress * math.pi))),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.28 + i * 0.12) + math.sin(animationProgress * 2 * math.pi + i) * 6;
      canvas.drawLine(Offset(size.width * 0.1, y), Offset(size.width * 0.9, y), cascadePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CityBackdropPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress || oldDelegate.isDark != isDark;
  }
}
