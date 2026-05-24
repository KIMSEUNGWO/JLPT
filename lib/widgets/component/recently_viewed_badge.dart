import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';

/// 최근 학습한 항목임을 나타내는 배지 위젯.
class RecentlyViewedBadge extends StatelessWidget {
  const RecentlyViewedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        '최근 학습',
        style: context.text.bodySmall?.copyWith(color: context.colors.onPrimary),
      ),
    );
  }
}
