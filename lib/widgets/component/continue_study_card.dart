import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/entity/view.dart';
import 'package:jlpt_app/settings/settings.dart';
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

class ContinueStudyCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_hasRecentView()) return const SizedBox.shrink();
    final groupSize = ref.watch(studyGroupSizeProvider);
    final target = _recentTarget(groupSize);
    if (target == null) return const SizedBox.shrink();

    final range = '${target.startIndex + 1}-${target.endIndex}';
    final remaining = target.totalCount - target.readCount;
    final course = ref.watch(activeCourseProvider);
    final captionStyle = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${course.displayName} ${target.level.label} 단어 $range',
          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              size: context.text.bodySmall!.fontSize,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text('최근 학습하던 묶음', style: captionStyle),
            const SizedBox(width: AppSpacing.sm),
            Text('남은 단어 $remaining개', style: captionStyle),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomProgressBar(current: target.readCount, total: target.totalCount),
        const SizedBox(height: AppSpacing.lg),
        GestureDetector(
          onTap: () => onContinue(target),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: context.colors.onPrimary,
                  size: 17,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '이어서 학습하기',
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onPrimary,
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

  ContinueStudyTarget? _recentTarget(int groupSize) {
    if (!_hasRecentView()) return null;
    return _targetFor(
      recentView.level!,
      recentView.index!,
      groupSize: groupSize,
      isRecent: true,
    );
  }

  ContinueStudyTarget? _targetFor(
    Level level,
    int groupIndex, {
    required int groupSize,
    required bool isRecent,
  }) {
    final words = wordsByLevel[level] ?? const <Word>[];
    if (words.isEmpty) return null;
    final start = groupIndex * groupSize;
    if (start >= words.length) return null;
    final end = min(start + groupSize, words.length);
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
