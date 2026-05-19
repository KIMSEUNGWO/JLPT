import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/entity/today.dart';
import 'package:jlpt_app/notifier/recently_view_notifier.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/notifier/timer_notifier.dart';
import 'package:jlpt_app/notifier/today_notifier.dart';
import 'package:jlpt_app/widgets/component/ads_banner.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';
import 'package:jlpt_app/widgets/component/record_component.dart';
import 'package:jlpt_app/widgets/component/record_row.dart';
import 'package:jlpt_app/widgets/component/recently_viewed_badge.dart';
import 'package:jlpt_app/widgets/component/study_streak_badge.dart';
import 'package:jlpt_app/widgets/component/test_stat_widget.dart';
import 'package:jlpt_app/widgets/component/title_and_widget.dart';
import 'package:jlpt_app/widgets/component/weekly_bars.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsByLevelProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () => context.push(AppRoutes.testResults),
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text('테스트 기록'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Greeting(),
                const SizedBox(height: 36),
                TitleAndWidget(
                  title: '오늘의 학습',
                  child: CustomContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final today = ref.watch(todayProvider);
                        final streakAsync = ref.watch(studyStreakProvider);
                        final weeklyAsync = ref.watch(weeklyStatsProvider);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RecordRow(
                              dataList: [
                                RecordData(
                                  title: '학습시간',
                                  value: TodayData.formatTimeToHours(
                                      today.hours),
                                ),
                                RecordData(
                                  title: '학습단어',
                                  value: '${today.wordCnt}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            streakAsync.when(
                              data: (s) => StudyStreakBadge(snapshot: s),
                              loading: () => const SizedBox(height: 18),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 10),
                            weeklyAsync.when(
                              data: (data) => WeeklyBars(data: data),
                              loading: () => const SizedBox(height: 40),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                wordsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 32),
                        const SizedBox(height: 8),
                        Text('단어 목록을 불러올 수 없습니다\n$e',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () =>
                              ref.invalidate(wordsByLevelProvider),
                          icon: const Icon(Icons.refresh),
                          label: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                  data: (wordsByLevel) => Column(
                    children: [
                      for (final level in Level.values) ...[
                        _LevelTile(
                          level: level,
                          words: wordsByLevel[level] ?? const [],
                        ),
                        if (level != Level.values.last)
                          const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 16),
                      const TestStatWidget(level: null),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
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
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize:
                Theme.of(context).textTheme.displayMedium!.fontSize,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘도 열심히 공부해볼까요?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
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

    return GestureDetector(
      onTap: () => context.push(AppRoutes.study(level.name)),
      child: CustomContainer(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: isRecent
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
        radius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(28),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'JLPT ${level.name}',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .fontSize,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${cycle[level]}회독'),
                  ],
                ),
                if (isRecent) const RecentlyViewedBadge(),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: Theme.of(context).textTheme.bodySmall!.fontSize,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 4),
                Text(
                  '학습시간 ${TodayData.formatTimeToHours(timer)}',
                  style: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.bodySmall!.fontSize,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
