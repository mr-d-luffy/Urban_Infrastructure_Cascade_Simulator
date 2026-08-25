import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CinematicBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CinematicBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      {'label': 'INTRO', 'icon': Icons.public_outlined, 'activeIcon': Icons.public},
      {'label': 'NETWORK', 'icon': Icons.hub_outlined, 'activeIcon': Icons.hub},
      {'label': 'SIMULATE', 'icon': Icons.bolt_outlined, 'activeIcon': Icons.bolt},
      {'label': 'ANALYTICS', 'icon': Icons.analytics_outlined, 'activeIcon': Icons.analytics},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              final color = isSelected
                  ? (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy)
                  : (isDark ? AppTheme.neutral.withValues(alpha: 0.6) : AppTheme.neutral);

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active indicator bar
                      Container(
                        height: 2,
                        width: 20,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      Icon(
                        isSelected ? (item['activeIcon'] as IconData) : (item['icon'] as IconData),
                        size: 20,
                        color: color,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: 1.0,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
