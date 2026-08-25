import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../common/cinematic_button.dart';
import 'city_backdrop_painter.dart';

class CinematicHero extends StatefulWidget {
  final VoidCallback onEnterSimulator;

  const CinematicHero({
    super.key,
    required this.onEnterSimulator,
  });

  @override
  State<CinematicHero> createState() => _CinematicHeroState();
}

class _CinematicHeroState extends State<CinematicHero> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _currentStageIndex = 0;
  final List<String> _stages = ['CITY', 'NETWORK', 'FAILURE', 'CASCADE', 'SIMULATION'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _animController.addListener(() {
      final newIndex = (_animController.value * _stages.length).floor().clamp(0, _stages.length - 1);
      if (newIndex != _currentStageIndex) {
        setState(() {
          _currentStageIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: (size.height * 0.60).clamp(400.0, 680.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated backdrop
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                return CustomPaint(
                  painter: CityBackdropPainter(
                    animationProgress: _animController.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),

          // Foreground Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Active stage pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    _stages[_currentStageIndex],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Main Headline
                Text(
                  'WHEN ONE SYSTEM FAILS,\nTHE CITY FOLLOWS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.25,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.5,
                    color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                  ),
                ),

                const SizedBox(height: 14),

                // Subtitle
                Text(
                  'Simulate. Understand. Recover.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.2,
                    color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.75),
                  ),
                ),

                const SizedBox(height: 28),

                // Enter Simulator Call-To-Action
                CinematicButton(
                  label: 'ENTER SIMULATOR',
                  icon: Icons.arrow_downward,
                  style: CinematicButtonStyle.primary,
                  onPressed: widget.onEnterSimulator,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),

                const SizedBox(height: 32),

                // Horizontal stage track indicator
                SizedBox(
                  width: math.min(size.width * 0.85, 360.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _stages.map((stage) {
                          final isCurrent = stage == _stages[_currentStageIndex];
                          return Text(
                            stage,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              letterSpacing: 1.0,
                              color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy)
                                  .withValues(alpha: isCurrent ? 0.95 : 0.4),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _animController.value,
                          backgroundColor: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                          ),
                          minHeight: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
