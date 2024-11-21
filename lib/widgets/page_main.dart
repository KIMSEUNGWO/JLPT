

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/domain/box/japan_word_box.dart';
import 'package:jlpt_app/notifier/entity/today.dart';
import 'package:jlpt_app/notifier/recently_view_notifier.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/notifier/timer_notifier.dart';
import 'package:jlpt_app/notifier/today_notifier.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';
import 'package:jlpt_app/widgets/component/record_component.dart';
import 'package:jlpt_app/widgets/component/record_row.dart';
import 'package:jlpt_app/widgets/component/title_and_widget.dart';
import 'package:jlpt_app/widgets/study/page_study_list.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {

  final List<Level> _levels = Level.values;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('안녕하세요',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: Theme.of(context).textTheme.displayMedium!.fontSize
                      ),
                    ),
                    const SizedBox(height: 4,),
                    Text('오늘도 열심히 공부해볼까요?',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36,),

                TitleAndWidget(
                  title: '오늘의 학습',
                  child: CustomContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Consumer(
                      builder: (context, ref, child) {
                        var watch = ref.watch(todayNotifier);

                        return RecordRow(
                          dataList: [
                            RecordData(title: '학습시간', value: TodayData.formatTimeToHours(watch.hours)),
                            RecordData(title: '학습단어', value: '${watch.wordCnt}'),
                            RecordData(title: '학습문법', value: '${watch.grammarCnt}'),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 28,),

                ValueListenableBuilder(
                  valueListenable: Hive.box(DBHive.JAPAN_WORDS_BOX).listenable(),
                  builder: (context, box, child) {
                    var boxData = box.get('words');
                    Map<Level, List<Word>> dbState = boxData?.words ?? {};
                    return Column(
                      children: _levels.expand((level) => [
                        Consumer(
                          builder: (context, ref, child) {
                            var recentlyView = ref.watch(recentlyViewNotifier).level == level;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return StudyListPage(
                                    level: level,
                                    words: dbState[level] ?? [],
                                  );
                                },));
                              },
                              child: CustomContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                border: recentlyView ? Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2
                                ) : null,
                                radius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(28),
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                child: Consumer(
                                  builder: (context, ref, child) {

                                    var studyCycle = ref.watch(studyCycleNotifier);
                                    int timer = ref.watch(timerNotifier)[level] ?? 0;

                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text('JLPT ${level.name}',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onPrimary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: Theme.of(context).textTheme.displaySmall!.fontSize,
                                                  ),
                                                ),
                                                const SizedBox(width: 6,),
                                                Text('${studyCycle[level]}회독'),
                                              ],
                                            ),
                                            if (recentlyView)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    borderRadius: BorderRadius.circular(12)
                                                ),
                                                child: Text('최근 학습',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: Theme.of(context).textTheme.bodySmall!.fontSize
                                                  ),
                                                ),
                                              )
                                          ],
                                        ),
                                        const SizedBox(height: 6,),

                                        Row(
                                          children: [
                                            Icon(Icons.access_time,
                                              size: Theme.of(context).textTheme.bodySmall!.fontSize,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                            const SizedBox(width: 4,),
                                            Text('학습시간 ${TodayData.formatTimeToHours(timer)}',
                                              style: TextStyle(
                                                  fontSize: Theme.of(context).textTheme.bodySmall!.fontSize
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16,),

                                        CustomProgressBar(
                                          current: dbState[level]?.where((e) => e.isRead).length ?? 0,
                                          total: dbState[level] == null || dbState[level]!.isEmpty ? 100 : dbState[level]!.length, // TODO 일단 100으로 해놓긴함
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        if (level != _levels.last) const SizedBox(height: 16,),
                      ]).toList(),
                    );
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
