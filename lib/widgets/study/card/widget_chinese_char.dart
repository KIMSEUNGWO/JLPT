
import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/domain/chinese_char.dart';

class ChineseCharWidget extends StatelessWidget {

  final ChineseChar char;

  const ChineseCharWidget({super.key, required this.char});

  @override
  Widget build(BuildContext context) {
    final contentStyle = context.text.bodyMedium?.copyWith(
      color: context.colors.onSurface,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Text(char.char, style: context.text.displayLarge),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('음독 : ', style: context.text.bodyMedium),
                Text(
                  char.soundReading.isEmpty ? '-' : char.soundReading.join(' · '),
                  style: contentStyle,
                ),
              ],
            ),
            Row(
              children: [
                Text('훈독 : ', style: context.text.bodyMedium),
                Text(
                  char.meanReading.isEmpty ? '-' : char.meanReading.join(' · '),
                  style: contentStyle,
                ),
              ],
            ),
            Row(
              children: [
                Text('한국한자 : ', style: context.text.bodyMedium),
                Text(char.koreanChar, style: contentStyle),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
