import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';

/// 학습 영역(히라가나/가타카나/JLPT 또는 그 하위 문자·단어)을 나타내는 카드.
/// 메인 학습 메뉴와 카나 허브에서 공통으로 쓴다.
class LearningAreaTile extends StatelessWidget {
  const LearningAreaTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.current = 0,
    this.total = 0,
    this.highlighted = false,
    this.showProgress = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int current;
  final int total;
  final VoidCallback onTap;

  /// 최근 학습한 영역이면 테두리로 강조.
  final bool highlighted;

  /// 하단 진행률 바 표시 여부.
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        border: highlighted
            ? Border.all(color: context.colors.primary, width: 2)
            : null,
        radius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.md),
          topRight: Radius.circular(28), // 특수 형태 — 카드 우측 상단만 더 둥글게
          bottomLeft: Radius.circular(AppRadius.md),
          bottomRight: Radius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          icon,
                          size: 20,
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: context.text.displaySmall?.copyWith(
                                color: context.colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              subtitle,
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
            if (showProgress) ...[
              const SizedBox(height: AppSpacing.lg),
              CustomProgressBar(
                current: current,
                total: total == 0 ? 100 : total,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
