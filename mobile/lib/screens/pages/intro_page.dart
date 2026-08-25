import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/simulation_controller.dart';
import '../../widgets/cinematic/cinematic_hero.dart';
import '../../widgets/common/cinematic_button.dart';

class IntroPage extends StatelessWidget {
  final VoidCallback onEnterNetwork;
  final VoidCallback onLaunchDemo;

  const IntroPage({
    super.key,
    required this.onEnterNetwork,
    required this.onLaunchDemo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<SimulationController>();

    return SingleChildScrollView(
      child: Column(
        children: [
          CinematicHero(
            onEnterSimulator: onEnterNetwork,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick Launch Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bolt, color: AppTheme.warning, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'QUICK DEMO SCENARIO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Trigger a catastrophic failure at the city Power Grid and watch the cascade propagate across Hospitals, Water Treatment, Transportation, and Emergency Services.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: isDark ? AppTheme.neutral.withValues(alpha: 0.9) : AppTheme.neutral,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CinematicButton(
                              label: 'Run Power Grid Demo',
                              icon: Icons.play_arrow,
                              style: CinematicButtonStyle.primary,
                              onPressed: () {
                                controller.loadDemoScenario();
                                controller.runSimulationPlayback();
                                onLaunchDemo();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // How it works info cards
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        icon: Icons.hub_outlined,
                        title: 'DEPENDENCY GRAPH',
                        subtitle: 'Visualizes 8 core urban services and their interconnections',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        icon: Icons.analytics_outlined,
                        title: 'CASCADE DEPTH',
                        subtitle: 'Measures multi-hop propagation and recovery durations',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              height: 1.3,
              color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
            ),
          ),
        ],
      ),
    );
  }
}
