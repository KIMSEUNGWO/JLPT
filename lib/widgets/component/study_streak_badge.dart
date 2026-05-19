import 'package:flutter/material.dart';
import 'package:jlpt_app/data/providers.dart';

/// `🔥 N일 연속 · 최고 M일` 한 줄. data 가 0/0 이어도 자리를 차지 (학습 동기 표시).
class StudyStreakBadge extends StatelessWidget {
  const StudyStreakBadge({super.key, required this.snapshot});

  final StreakSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        const Text('🔥', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          '${snapshot.current}일 연속',
          style: TextStyle(
            color: color,
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '· 최고 ${snapshot.best}일',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
          ),
        ),
      ],
    );
  }
}
