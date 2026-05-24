
import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';

class TitleAndWidget extends StatelessWidget {

  final String title;
  final EdgeInsets? titlePadding;
  final Widget child;
  final TextStyle? textStyle;

  const TitleAndWidget({super.key, required this.title, this.titlePadding, this.textStyle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: titlePadding ?? const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(title, style: textStyle ?? context.text.labelLarge),
        ),

        const SizedBox(height: AppSpacing.md),

        child
      ],
    );
  }
}
