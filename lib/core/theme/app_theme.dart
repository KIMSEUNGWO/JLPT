import 'package:flutter/material.dart';
import 'package:jlpt_app/core/theme/app_colors.dart';

abstract class AppTheme {
  static const _appBarTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const _textTheme = TextTheme(
    headlineLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 36,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    headlineMedium: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.4,
    ),
    displayLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 26,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    displayMedium: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 21,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    displaySmall: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      color: AppColors.textTertiary,
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
  );

  static ThemeData get light => ThemeData(
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.background,
      titleTextStyle: _appBarTitle,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.surface,
      surface: AppColors.card,
      surfaceContainerHighest: AppColors.divider,
      onPrimary: AppColors.textPrimary,
      onSurface: AppColors.textSecondary,
      onTertiary: AppColors.textTertiary,
      error: AppColors.error,
    ),
    textTheme: _textTheme,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.snackBar.withValues(alpha: .85),
      contentTextStyle: _textTheme.bodyLarge?.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
