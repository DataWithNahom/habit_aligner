import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0C0F14);
  static const surface = Color(0xFF121722);
  static const surface2 = Color(0xFF1A2231);
  static const accent = Color(0xFF8EA3BD);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFB020);
  static const driftRiskHigh = Color(0xFFE57373);
  static const divider = Color(0xFF2C3445);
}

class AppTypography {
  static const display = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  static const title = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const meta = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.accent,
      secondary: AppColors.accent,
      outline: AppColors.divider,
    ),
    textTheme: const TextTheme(
      headlineMedium: AppTypography.display,
      titleMedium: AppTypography.title,
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.meta,
    ),
  );
}
