import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/study_level_kind.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/entity/today.dart';
import 'package:jlpt_app/notifier/recently_view_notifier.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/notifier/timer_notifier.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';
import 'package:jlpt_app/widgets/component/recently_viewed_badge.dart';
import 'package:jlpt_app/widgets/component/test_stat_widget.dart';

class JlptLevelsPage extends ConsumerWidget {
  const JlptLevelsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsByLevelProvider);
    final course = ref.watch(activeCourseProvider);
    final jlptLevels = course.levels.where((level) => level.isJlpt).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${course.displayName} 학습'),
        centerTitle: false,
        backgroundColor: context.colors.surface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: wordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('단어 목록을 불러올 수 없습니다\n$e')),
            data: (wordsByLevel) => ListView.separated(
              itemCount: jlptLevels.length + 1,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) {
                if (index == jlptLevels.length) {
                  return const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.lg),
                    child: TestStatWidget(level: null),
                  );
                }
                final level = jlptLevels[index];
                return _JlptLevelTile(
                  level: level,
                  words: wordsByLevel[level] ?? const [],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _JlptLevelTile extends ConsumerWidget {
  const _JlptLevelTile({required this.level, required this.words});

  final Level level;
  final List<Word> words;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(recentlyViewProvider);
    final isRecent = view.level == level;
    final cycle = ref.watch(studyCycleProvider);
    final timer = ref.watch(timerProvider)[level] ?? 0;
    final course = ref.watch(activeCourseProvider);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.study(level.code)),
      child: CustomContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        border: isRecent
            ? Border.all(color: context.colors.primary, width: 2)
            : null,
        radius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.md),
          topRight: Radius.circular(28),
          bottomLeft: Radius.circular(AppRadius.md),
          bottomRight: Radius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${course.displayName} ${level.label}',
                      style: context.text.displaySmall?.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('${cycle[level]}회독'),
                  ],
                ),
                if (isRecent) const RecentlyViewedBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: context.text.bodySmall!.fontSize,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '학습시간 ${TodayData.formatTimeToHours(timer)}',
                  style: context.text.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomProgressBar(
              current: words.where((w) => w.isRead).length,
              total: words.isEmpty ? 100 : words.length,
            ),
          ],
        ),
      ),
    );
  }
}
