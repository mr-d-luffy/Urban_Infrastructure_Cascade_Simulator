import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/service_model.dart';

class ServiceNodeWidget extends StatelessWidget {
  final ServiceModel service;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceNodeWidget({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stateColor = AppTheme.stateColor(service.state);
    final icon = AppTheme.categoryIcon(service.category);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 140,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy)
                : stateColor.withValues(alpha: service.state == 'HEALTHY' ? 0.3 : 0.8),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: (isDark ? Colors.white : AppTheme.primaryNavy).withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
              )
            else if (service.state == 'FAILED' || service.state == 'DEGRADED')
              BoxShadow(
                color: stateColor.withValues(alpha: 0.25),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Category Icon + Service Name
            Row(
              children: [
                Icon(icon, size: 14, color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Row: State indicator dot + State text + Criticality
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: stateColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  service.state,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: stateColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '★${service.criticality}',
                  style: TextStyle(
                    fontSize: 8,
                    color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
