import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final IconData? icon;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(
                  icon,
                  size: 13,
                  color: isDark ? AppTheme.neutral.withValues(alpha: 0.6) : AppTheme.neutral.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
              ),
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(
              hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                color: isDark ? AppTheme.neutral.withValues(alpha: 0.7) : AppTheme.neutral,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
