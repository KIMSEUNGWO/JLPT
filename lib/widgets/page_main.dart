import 'package:jlpt_app/widgets/component/recently_viewed_badge.dart';
import 'package:jlpt_app/app/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/level.dart';
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
import 'package:jlpt_app/widgets/component/test_stat_widget.dart';
import 'package:jlpt_app/widgets/component/title_and_widget.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final List<Level> _levels = Level.values;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
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
                        fontSize:
                            Theme.of(context).textTheme.bodyLarge!.fontSize,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                TitleAndWidget(
                  title: '오늘의 학습',
                  child: CustomContainer(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final today = ref.watch(todayProvider);
                        return RecordRow(dataList: [
                          RecordData(
                              title: '학습시간',
                              value: TodayData.formatTimeToHours(today.hours)),
                          RecordData(
                              title: '학습단어',
                              value: '${today.wordCnt}'),
                        ]);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                wordsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (wordsByLevel) => Column(
                    children: [
                      ..._levels.expand((level) => [
                            Consumer(
                              builder: (context, ref, _) {
                                final recentlyView = ref
                                        .watch(recentlyViewProvider)
                                        .level ==
                                    level;
                                final studyCycle =
                                    ref.watch(studyCycleProvider);
                                final timer =
                                    ref.watch(timerProvider)[level] ?? 0;
                                final levelWords = wordsByLevel[level] ?? [];

                                return GestureDetector(
                                  onTap: () => context.push(
                                    AppRoutes.study(level.name),
                                    extra: levelWords,
                                  ),
                                  child: CustomContainer(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    border: recentlyView
                                        ? Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 2)
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(children: [
                                              Text(
                                                'JLPT ${level.name}',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall!
                                                      .fontSize,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text('${studyCycle[level]}회독'),
                                            ]),
                                            if (recentlyView)
                                              const RecentlyViewedBadge(),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(children: [
                                          Icon(
                                            Icons.access_time,
                                            size: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .fontSize,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '학습시간 ${TodayData.formatTimeToHours(timer)}',
                                            style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .fontSize,
                                            ),
                                          ),
                                        ]),
                                        const SizedBox(height: 16),
                                        CustomProgressBar(
                                          current: levelWords
                                              .where((e) => e.isRead)
                                              .length,
                                          total: levelWords.isEmpty
                                              ? 100
                                              : levelWords.length,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (level != _levels.last)
                              const SizedBox(height: 16),
                          ]),
                      const SizedBox(height: 16),
                      TestStatWidget(level: null),
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
