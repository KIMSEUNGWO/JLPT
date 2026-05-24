import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_colors.dart';

/// `ColorScheme` 의 표준 슬롯에 의미가 안 맞는 보조 색들을 묶은 ThemeExtension.
///
/// 위젯에서는 `context.feedback.correctText` 같은 형태로 접근한다
/// (`theme_x.dart` 의 `ThemeX.feedback` 확장 참고).
@immutable
class AppFeedbackColors extends ThemeExtension<AppFeedbackColors> {
  const AppFeedbackColors({
    required this.textTertiary,
    required this.correctText,
    required this.correctBackground,
    required this.incorrectText,
    required this.incorrectBackground,
    required this.snackBar,
    required this.cardShadow,
    required this.inactiveChart,
    required this.primaryTint,
  });

  /// 정답·진행률·연한 강조 같이 textSecondary 보다 더 흐린 텍스트.
  final Color textTertiary;
  final Color correctText;
  final Color correctBackground;
  final Color incorrectText;
  final Color incorrectBackground;

  /// SnackBar 배경(어두운 회색).
  final Color snackBar;

  /// 카드 그림자 색. `AppShadow.card` 가 이 값을 받아 현재 테마에 맞는 그림자를 만든다.
  final Color cardShadow;

  /// 비활성 차트·진행률 트랙 회색.
  final Color inactiveChart;

  /// primary 의 연한 변형. 선택 상태/배경 강조에 사용.
  /// (`colorScheme.primaryContainer` 와 동일 값이지만, 의미 강조용 별도 슬롯.)
  final Color primaryTint;

  /// Light 변형. `AppTheme.light` 에서 등록.
  static const AppFeedbackColors light = AppFeedbackColors(
    textTertiary: AppColors.textTertiary,
    correctText: AppColors.correctText,
    correctBackground: AppColors.correctBackground,
    incorrectText: AppColors.incorrectText,
    incorrectBackground: AppColors.incorrectBackground,
    snackBar: AppColors.snackBar,
    cardShadow: AppColors.cardShadow,
    inactiveChart: AppColors.inactiveChart,
    primaryTint: AppColors.primaryTint,
  );

  @override
  AppFeedbackColors copyWith({
    Color? textTertiary,
    Color? correctText,
    Color? correctBackground,
    Color? incorrectText,
    Color? incorrectBackground,
    Color? snackBar,
    Color? cardShadow,
    Color? inactiveChart,
    Color? primaryTint,
  }) {
    return AppFeedbackColors(
      textTertiary: textTertiary ?? this.textTertiary,
      correctText: correctText ?? this.correctText,
      correctBackground: correctBackground ?? this.correctBackground,
      incorrectText: incorrectText ?? this.incorrectText,
      incorrectBackground: incorrectBackground ?? this.incorrectBackground,
      snackBar: snackBar ?? this.snackBar,
      cardShadow: cardShadow ?? this.cardShadow,
      inactiveChart: inactiveChart ?? this.inactiveChart,
      primaryTint: primaryTint ?? this.primaryTint,
    );
  }

  @override
  AppFeedbackColors lerp(ThemeExtension<AppFeedbackColors>? other, double t) {
    if (other is! AppFeedbackColors) return this;
    return AppFeedbackColors(
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      correctText: Color.lerp(correctText, other.correctText, t)!,
      correctBackground: Color.lerp(
        correctBackground,
        other.correctBackground,
        t,
      )!,
      incorrectText: Color.lerp(incorrectText, other.incorrectText, t)!,
      incorrectBackground: Color.lerp(
        incorrectBackground,
        other.incorrectBackground,
        t,
      )!,
      snackBar: Color.lerp(snackBar, other.snackBar, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      inactiveChart: Color.lerp(inactiveChart, other.inactiveChart, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
    );
  }
}
