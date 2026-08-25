import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isPulsing;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.isPulsing = false,
    this.fontSize = 10,
  });

  factory StatusBadge.forState(String state, {double fontSize = 10}) {
    final color = AppTheme.stateColor(state);
    return StatusBadge(
      label: state.toUpperCase(),
      color: color,
      fontSize: fontSize,
    );
  }

  factory StatusBadge.forConnection(String connectionState, {bool compact = false}) {
    switch (connectionState) {
      case 'postgres':
        return StatusBadge(
          label: compact ? 'POSTGRES' : 'POSTGRESQL CONNECTED',
          color: AppTheme.success,
          fontSize: compact ? 9 : 10,
        );
      case 'memory':
        return StatusBadge(
          label: compact ? 'MEMORY' : 'IN-MEMORY FALLBACK',
          color: AppTheme.warning,
          fontSize: compact ? 9 : 10,
        );
      case 'checking':
        return StatusBadge(
          label: compact ? 'CONNECTING...' : 'CHECKING BACKEND...',
          color: AppTheme.neutral,
          isPulsing: true,
          fontSize: compact ? 9 : 10,
        );
      case 'offline':
      default:
        return StatusBadge(
          label: compact ? 'OFFLINE' : 'OFFLINE ENGINE',
          color: AppTheme.critical,
          fontSize: compact ? 9 : 10,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
