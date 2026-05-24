import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_colors.dart';
import 'package:jlpt_app/core/theme/app_feedback_colors.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/app_text_extras.dart';
import 'package:jlpt_app/core/theme/app_typography.dart';

/// 앱 테마 진입점. light 만 노출하지만 내부적으로 `ColorScheme`/`TextTheme`/
/// 보조 `ThemeExtension` 들을 한 자리에서 조립한다.
///
/// dark 추가 시에는 같은 `_build` 에 dark `ColorScheme` 과 `AppFeedbackColors`
/// 를 주입하고, 앱 연결 여부는 `MaterialApp.darkTheme/themeMode` 에서 결정한다.
abstract class AppTheme {
  static ThemeData get light =>
      _build(colorScheme: _lightColorScheme, feedback: AppFeedbackColors.light);

  // ── ColorScheme (Material 의미에 맞춘 매핑) ─────────────────────────────
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryTint,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.surface,
    onSecondary: AppColors.textPrimary,
    surface: AppColors.card,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.surface,
    surfaceContainerHigh: AppColors.surfaceAlt,
    surfaceContainerHighest: AppColors.divider,
    outline: AppColors.divider,
    outlineVariant: AppColors.inactiveChart,
    error: AppColors.error,
    onError: AppColors.onError,
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required AppFeedbackColors feedback,
  }) {
    final textTheme = AppTypography.textTheme(colorScheme, feedback);
    final textExtras = AppTextExtras.from(colorScheme);
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      fontFamily: 'Pretendard',
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,

      // AppBar — kAppBarShape 대체
      appBarTheme: AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surfaceContainerLowest,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
        shape: AppRadius.appBarShape,
      ),

      // Cards / Dialog / BottomSheet — 라디우스 토큰 일원화
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),

      // Buttons — 텍스트는 labelLarge 슬롯 사용
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Divider / Icon
      dividerTheme: DividerThemeData(color: colorScheme.outline, thickness: 1),
      iconTheme: IconThemeData(color: colorScheme.onSurface),

      // SnackBar — 어두운 배경은 feedback, 텍스트는 Theme 전경 토큰 사용
      snackBarTheme: SnackBarThemeData(
        backgroundColor: feedback.snackBar.withValues(alpha: .85),
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // 보조 토큰 등록
      extensions: <ThemeExtension<dynamic>>[feedback, textExtras],
    );
  }
}
