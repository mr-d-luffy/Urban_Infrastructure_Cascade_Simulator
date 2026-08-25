import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/simulation_controller.dart';
import '../../providers/theme_controller.dart';
import '../common/api_endpoint_dialog.dart';
import '../common/status_badge.dart';

class CinematicNavBar extends StatelessWidget {
  final VoidCallback? onEnterSimulator;

  const CinematicNavBar({
    super.key,
    this.onEnterSimulator,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final simController = context.watch<SimulationController>();
    final isDark = themeController.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkSurface : AppTheme.lightSurface).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Brand Logo & Title (Flex-safe)
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.account_tree_outlined,
                      size: 15,
                      color: isDark ? AppTheme.primaryNavy : AppTheme.pureWhite,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CASCADE SIMULATOR',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                          ),
                        ),
                        Text(
                          'Urban Infrastructure',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8.5,
                            color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // Compact Connection Status badge (clickable to configure backend)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const ApiEndpointDialog(),
                );
              },
              child: StatusBadge.forConnection(
                simController.connectionState,
                compact: true,
              ),
            ),

            const SizedBox(width: 4),

            // Backend Settings Button
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Backend API Settings',
              icon: Icon(
                Icons.settings_ethernet,
                size: 17,
                color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const ApiEndpointDialog(),
                );
              },
            ),

            // Theme Toggle Button
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 17,
                color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
              ),
              onPressed: () => themeController.toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}
