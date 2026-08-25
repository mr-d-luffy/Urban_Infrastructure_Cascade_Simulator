import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors from design.md
  static const Color primaryNavy = Color(0xFF1D3045);
  static const Color darkBackground = Color(0xFF0B131C);
  static const Color darkSurface = Color(0xFF132230);
  static const Color lightBackground = Color(0xFFF5F7F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF2E8B57);
  static const Color warning = Color(0xFFD49A2A);
  static const Color critical = Color(0xFFC94B4B);
  static const Color degraded = Color(0xFFC98A35);
  static const Color neutral = Color(0xFF7B8794);

  // Border colors
  static const Color lightBorder = Color(0x1A1D3045); // 10% navy
  static const Color darkBorder = Color(0x1AFFFFFF);  // 10% white

  // Dot backgrounds
  static const Color lightGridDots = Color(0xFFD8DEE4);
  static const Color darkGridDots = Color(0xFF2C3E50);

  static Color stateColor(String state) {
    switch (state.toUpperCase()) {
      case 'HEALTHY':
      case 'RECOVERED':
        return success;
      case 'DEGRADED':
        return degraded;
      case 'FAILED':
        return critical;
      case 'RECOVERING':
        return warning;
      default:
        return neutral;
    }
  }

  static IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'energy':
        return Icons.bolt;
      case 'healthcare':
        return Icons.local_hospital;
      case 'water':
        return Icons.water_drop;
      case 'transport':
        return Icons.directions_subway;
      case 'communication':
        return Icons.cell_tower;
      case 'emergency':
        return Icons.emergency;
      case 'residential':
        return Icons.home;
      case 'waste':
        return Icons.delete_outline;
      default:
        return Icons.category;
    }
  }

  static ThemeData lightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        surface: lightSurface,
        onPrimary: pureWhite,
        onSurface: primaryNavy,
        error: critical,
      ),
      cardTheme: const CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: lightBorder),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: primaryNavy,
        displayColor: primaryNavy,
      ),
      dividerColor: lightBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: primaryNavy,
        elevation: 0,
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: pureWhite,
        surface: darkSurface,
        onPrimary: primaryNavy,
        onSurface: pureWhite,
        error: critical,
      ),
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: darkBorder),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: pureWhite,
        displayColor: pureWhite,
      ),
      dividerColor: darkBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: pureWhite,
        elevation: 0,
      ),
    );
  }
}
