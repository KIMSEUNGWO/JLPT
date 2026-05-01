import 'package:flutter/material.dart';

/// 최근 학습한 항목임을 나타내는 배지 위젯.
class RecentlyViewedBadge extends StatelessWidget {
  const RecentlyViewedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '최근 학습',
        style: TextStyle(
          color: Colors.white,
          fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
        ),
      ),
    );
  }
}
