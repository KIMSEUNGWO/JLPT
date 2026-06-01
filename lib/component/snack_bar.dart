import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';

class CustomSnackBar {
  static const CustomSnackBar instance = CustomSnackBar();
  const CustomSnackBar();

  void message(BuildContext context, String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: theme.snackBarTheme.contentTextStyle),
        duration: const Duration(seconds: 2), // 지속시간
        // floating 이어야 margin 이 적용된다. 하단에서 20px 띄운다.
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: 20,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}
