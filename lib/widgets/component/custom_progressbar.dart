
import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';

class CustomProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final Widget Function(int current, int total, int percent)? topWidget;

  /// 트랙은 6px 라 라디우스 토큰(sm=8) 보다 작아야 하므로 별도 const 로 유지.
  static const double _barRadius = 4;

  const CustomProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.topWidget,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = current / total;
    final percentage = (progress * 100).toInt();
    final captionStyle = context.text.bodySmall?.copyWith(
      color: context.feedback.textTertiary,
    );

    return Column(
      children: [
        topWidget != null
            ? topWidget!(current, total, percentage)
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$current/$total', style: captionStyle),
                  Text('$percentage%', style: captionStyle),
                ],
              ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_barRadius),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.feedback.inactiveChart,
                    borderRadius: BorderRadius.circular(_barRadius),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(_barRadius),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
