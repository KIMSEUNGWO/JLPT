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
import 'package:jlpt_app/notifier/entity/today.dart';
import 'package:jlpt_app/notifier/recently_view_notifier.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/notifier/timer_notifier.dart';
import 'package:jlpt_app/widgets/component/ads_banner.dart';
import 'package:jlpt_app/widgets/component/continue_study_card.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';
import 'package:jlpt_app/widgets/component/recently_viewed_badge.dart';
import 'package:jlpt_app/widgets/component/test_stat_widget.dart';
import 'package:jlpt_app/widgets/component/title_and_widget.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsByLevelProvider);
    final course = ref.watch(activeCourseProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () => context.push(AppRoutes.testResults),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Center(child: Text('테스트 기록')),
            ),
          ),
          IconButton(
            tooltip: '환경설정',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Greeting(),
                const SizedBox(height: AppSpacing.xxxl),
                Consumer(
                  builder: (context, ref, _) {
                    final recentView = ref.watch(recentlyViewProvider);
                    final hasRecent =
                        recentView.level != null &&
                        recentView.type == PracticeType.WORD &&
                        recentView.index != null;
                    if (!hasRecent) return const SizedBox.shrink();

                    return Column(
                      children: [
                        TitleAndWidget(
                          title: '오늘의 학습',
                          child: CustomContainer(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            child: wordsAsync.when(
                              loading: () => const SizedBox(
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (_, __) => const SizedBox(
                                height: 80,
                                child: Center(child: Text('학습 정보를 불러올 수 없습니다')),
                              ),
                              data: (wordsByLevel) => ContinueStudyCard(
                                wordsByLevel: wordsByLevel,
                                recentView: recentView,
                                onContinue: (target) async {
                                  ref
                                      .read(recentlyViewProvider.notifier)
                                      .view(
                                        level: target.level,
                                        type: PracticeType.WORD,
                                        index: target.groupIndex,
                                      );
                                  await context.push(
                                    AppRoutes.studyGroupFull(target.level.code),
                                    extra: StudyGroupArgs(
                                      level: target.level,
                                      startIndex: target.startIndex,
                                      endIndex: target.endIndex,
                                    ),
                                  );
                                  ref.invalidate(wordsByLevelProvider);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                      ],
                    );
                  },
                ),
                wordsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 32),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '단어 목록을 불러올 수 없습니다\n$e',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton.icon(
                          onPressed: () => ref.invalidate(wordsByLevelProvider),
                          icon: const Icon(Icons.refresh),
                          label: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                  data: (wordsByLevel) => Column(
                    children: [
                      for (final level in course.levels) ...[
                        _LevelTile(
                          level: level,
                          words: wordsByLevel[level] ?? const [],
                        ),
                        if (level != course.levels.last)
                          const SizedBox(height: AppSpacing.lg),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      const TestStatWidget(level: null),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const SimpleBannerAd(height: 100),
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요',
          style: context.text.displayMedium?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '오늘도 열심히 공부해볼까요?',
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LevelTile extends ConsumerWidget {
  const _LevelTile({required this.level, required this.words});
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
          topRight: Radius.circular(28), // 특수 형태 — 카드 우측 상단만 더 둥글게
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
