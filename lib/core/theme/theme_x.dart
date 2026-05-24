import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_feedback_colors.dart';
import 'package:jlpt_app/core/theme/app_text_extras.dart';

/// `BuildContext` 에서 테마 토큰에 짧게 접근하기 위한 확장.
///
/// 사용 예:
/// ```dart
/// final cs = context.colors;
/// Text('hello', style: context.text.bodyLarge);
/// Container(color: context.feedback.correctBackground);
/// Text(score, style: context.scoreText);
/// ```
extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;

  AppFeedbackColors get feedback =>
      Theme.of(this).extension<AppFeedbackColors>() ?? AppFeedbackColors.light;
  TextStyle get scoreText =>
      Theme.of(this).extension<AppTextExtras>()?.score ??
      AppTextExtras.from(colors).score;
}
