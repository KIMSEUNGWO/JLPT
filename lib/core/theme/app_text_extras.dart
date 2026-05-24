import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_typography.dart';

/// Material `TextTheme` 슬롯 외에 보조 글꼴이 필요한 자리(점수·결과 강조 등)
/// 를 담는 ThemeExtension. `context.scoreText` 로 접근.
@immutable
class AppTextExtras extends ThemeExtension<AppTextExtras> {
  const AppTextExtras({required this.score});

  /// Tmoney 글꼴 기반 점수 강조 스타일. 사이즈 21 / weight w600.
  final TextStyle score;

  static AppTextExtras from(ColorScheme colorScheme) =>
      AppTextExtras(score: AppTypography.score(colorScheme));

  @override
  AppTextExtras copyWith({TextStyle? score}) =>
      AppTextExtras(score: score ?? this.score);

  @override
  AppTextExtras lerp(ThemeExtension<AppTextExtras>? other, double t) {
    if (other is! AppTextExtras) return this;
    return AppTextExtras(score: TextStyle.lerp(score, other.score, t)!);
  }
}
