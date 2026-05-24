import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';

class RecordComponent extends StatelessWidget {
  final RecordData data;
  final double? titleSize;
  final double? valueSize;

  const RecordComponent({
    super.key,
    required this.data,
    this.titleSize,
    this.valueSize,
  });

  @override
  Widget build(BuildContext context) {
    final base = context.text.displaySmall!.copyWith(
      color: context.colors.primary,
      fontWeight: FontWeight.w600,
    );
    return Column(
      children: [
        Text(
          data.value,
          style: valueSize == null ? base : base.copyWith(fontSize: valueSize),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          data.title,
          style: context.text.bodyMedium?.copyWith(fontSize: titleSize),
        ),
      ],
    );
  }
}

class RecordData {
  final String title;
  final String value;

  RecordData({required this.title, required this.value});
}
