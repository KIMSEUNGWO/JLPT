import 'package:flutter/material.dart';
import 'package:jlpt_app/core/theme/app_colors.dart';

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.background,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.surface,
          onPrimary: AppColors.textPrimary,
          onSurface: AppColors.textSecondary,
          onTertiary: AppColors.textTertiary,
          error: AppColors.error,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, height: 1.4),
          displayMedium: TextStyle(fontSize: 21, fontWeight: FontWeight.w600, height: 1.4),
          displaySmall: TextStyle(fontSize: 16),
          bodyLarge: TextStyle(fontSize: 14),
          bodyMedium: TextStyle(fontSize: 12),
          bodySmall: TextStyle(fontSize: 10),
        ),
      );
}
