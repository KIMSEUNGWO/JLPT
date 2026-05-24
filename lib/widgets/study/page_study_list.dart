import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/app/route_args.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/recently_view_notifier.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/notifier/study_session_notifier.dart';
import 'package:jlpt_app/notifier/timer_notifier.dart';
import 'package:jlpt_app/settings/settings.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';
import 'package:jlpt_app/widgets/component/recently_viewed_badge.dart';
import 'package:jlpt_app/widgets/component/test_stat_widget.dart';
import 'package:jlpt_app/widgets/modal/congratulations_modal.dart';

class StudyListPage extends ConsumerWidget {
  final Level level;

  const StudyListPage({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsByLevelProvider);
    final course = ref.watch(activeCourseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${course.displayName} ${level.label}'),
        centerTitle: false,
        backgroundColor: context.colors.surface,
        actions: [
          wordsAsync.maybeWhen(
            data: (map) {
              final words = map[level] ?? const <Word>[];
              return _ProgressBadge(percent: _percent(words));
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: AppSpacing.sm),
          Consumer(
            builder: (context, ref, _) {
              final cycle = ref.watch(studyCycleProvider);
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
                  '${cycle[level]}회독',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xl),
        ],
      ),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (map) {
          final words = map[level] ?? const <Word>[];
          if (words.isEmpty) {
            return const Center(child: Text('단어가 없습니다'));
          }
          return _StudyList(level: level, words: words);
        },
      ),
    );
  }

  int _percent(List<Word> words) {
    if (words.isEmpty) return 0;
    final read = words.where((w) => w.isRead).length;
    return (read / words.length * 100).round();
  }
}

class _StudyList extends ConsumerStatefulWidget {
  const _StudyList({required this.level, required this.words});
  final Level level;
  final List<Word> words;

  @override
  ConsumerState<_StudyList> createState() => _StudyListState();
}

class _StudyListState extends ConsumerState<_StudyList> {
  Future<void> _onCardReturned() async {
    ref.invalidate(wordsByLevelProvider);
    final latestWords = await ref
        .read(wordRepositoryProvider)
        .getByLevel(widget.level);
    if (!mounted) return;

    final allRead = latestWords.every((w) => w.isRead);
    if (!allRead) return;
    final session = ref.read(studySessionProvider.notifier);
    await showDialog<void>(
      context: context,
      builder: (ctx) => CongratulationsModal(
        level: widget.level,
        wordsLearned: latestWords.length,
        studyTime: ref.read(timerProvider.notifier).getLevelTime(widget.level),
        onNextLevelTap: () async {
          Navigator.of(ctx).pop();
          await session.completeCycle(widget.level);
        },
        onViewTestTap: () async {
          Navigator.of(ctx).pop();
          await session.completeCycle(widget.level);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.words;
    final groupSize = ref.watch(studyGroupSizeProvider);
    final groupCount = (words.length / groupSize).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: ListView.separated(
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
        itemCount: groupCount + 1,
        itemBuilder: (context, index) {
          if (groupCount == index) {
            return TestStatWidget(level: widget.level);
          }
          final start = index * groupSize;
          final end = min((index + 1) * groupSize, words.length);
          final innerWords = words.sublist(start, end);

          return Consumer(
            builder: (context, ref, _) {
              final view = ref.watch(recentlyViewProvider);
              final isRecent =
                  view.level == widget.level &&
                  view.type == PracticeType.WORD &&
                  view.index == index;

              return GestureDetector(
                onTap: () async {
                  ref
                      .read(recentlyViewProvider.notifier)
                      .view(
                        level: widget.level,
                        type: PracticeType.WORD,
                        index: index,
                      );
                  await context.push(
                    AppRoutes.studyGroupFull(widget.level.code),
                    extra: StudyGroupArgs(
                      level: widget.level,
                      startIndex: start,
                      endIndex: end,
                    ),
                  );
                  if (mounted) await _onCardReturned();
                },
                child: CustomContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  radius: BorderRadius.circular(AppRadius.md),
                  border: isRecent
                      ? Border.all(color: context.colors.primary, width: 2)
                      : null,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '단어 ${start + 1}-$end',
                            style: context.text.displaySmall?.copyWith(
                              color: context.colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isRecent) const RecentlyViewedBadge(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CustomProgressBar(
                        current: innerWords.where((w) => w.isRead).length,
                        total: innerWords.length,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        '전체진도 $percent%',
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
