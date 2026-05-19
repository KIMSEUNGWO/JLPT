import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jlpt_app/domain/constant.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/entity/view.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';

class ContinueStudyTarget {
  const ContinueStudyTarget({
    required this.level,
    required this.groupIndex,
    required this.startIndex,
    required this.endIndex,
    required this.readCount,
    required this.totalCount,
    required this.isRecent,
  });

  final Level level;
  final int groupIndex;
  final int startIndex;
  final int endIndex;
  final int readCount;
  final int totalCount;
  final bool isRecent;
}

class ContinueStudyCard extends StatelessWidget {
  const ContinueStudyCard({
    super.key,
    required this.wordsByLevel,
    required this.recentView,
    required this.onContinue,
  });

  final Map<Level, List<Word>> wordsByLevel;
  final ViewData recentView;
  final Future<void> Function(ContinueStudyTarget target) onContinue;

  @override
  Widget build(BuildContext context) {
    if (!_hasRecentView()) return const SizedBox.shrink();
    final target = _recentTarget();
    if (target == null) return const SizedBox.shrink();

    final range = '${target.startIndex + 1}-${target.endIndex}';
    final remaining = target.totalCount - target.readCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JLPT ${target.level.name} 단어 $range',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: Theme.of(context).textTheme.displaySmall!.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              size: Theme.of(context).textTheme.bodySmall!.fontSize,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              '최근 학습하던 묶음',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '남은 단어 $remaining개',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomProgressBar(current: target.readCount, total: target.totalCount),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => onContinue(target),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 17,
                ),
                const SizedBox(width: 6),
                Text(
                  '이어서 학습하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _hasRecentView() =>
      recentView.level != null &&
      recentView.type == PracticeType.WORD &&
      recentView.index != null;

  ContinueStudyTarget? _recentTarget() {
    if (!_hasRecentView()) return null;
    return _targetFor(recentView.level!, recentView.index!, isRecent: true);
  }

  ContinueStudyTarget? _targetFor(
    Level level,
    int groupIndex, {
    required bool isRecent,
  }) {
    final words = wordsByLevel[level] ?? const <Word>[];
    if (words.isEmpty) return null;
    final start = groupIndex * Constant.GROUP_SIZE;
    if (start >= words.length) return null;
    final end = min(start + Constant.GROUP_SIZE, words.length);
    final group = words.sublist(start, end);
    return ContinueStudyTarget(
      level: level,
      groupIndex: groupIndex,
      startIndex: start,
      endIndex: end,
      readCount: group.where((w) => w.isRead).length,
      totalCount: group.length,
      isRecent: isRecent,
    );
  }
}
