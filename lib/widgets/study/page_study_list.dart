import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:jlpt_app/component/snack_bar.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/constant.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/recently_view_notifier.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/notifier/timer_notifier.dart';
import 'package:jlpt_app/widgets/component/test_stat_widget.dart';
import 'package:jlpt_app/widgets/modal/congratulationsModal.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/widgets/study/card/page_study.dart';

class StudyListPage extends ConsumerStatefulWidget {
  
  final Level level;
  final List<Word> words;


  const StudyListPage({super.key, required this.level, required this.words});

  @override
  createState() => _StudyListPageState();
}

class _StudyListPageState extends ConsumerState<StudyListPage> {

  late final PageController _pageController;

  late final List<Word> _stateWords;

  int _currentPage = 0;

  void _wordsInitial() {
    setState(() {
      for (var e in _stateWords) {
        e.isRead = false;
      }
    });
  }

  getSeconds(int seconds) {
    ref.read(timerNotifier.notifier).setTimer(ref, widget.level, seconds);

    var allRead = _stateWords.every((element) => element.isRead,);
    if (allRead) {
      showDialog(context: context,
        builder: (context) => CongratulationsModal(
          level: widget.level,
          wordsLearned: _stateWords.length,
          studyTime: ref.read(timerNotifier.notifier).getLevelTime(widget.level),
          onNextLevelTap: () async {
            Navigator.of(context).pop();
            _wordsInitial();
            await DBHive.instance.initialWords(ref, widget.level);
          },
          onViewTestTap: () async {
            Navigator.of(context).pop();
            _wordsInitial();
            await DBHive.instance.initialWords(ref, widget.level);
          },
        ),
      );
    }
  }

  _onChangePage(int page) {
    if (page == _currentPage) return;

    if (page != 0) {
      CustomSnackBar.instance.message(context, '준비중입니다.');
      return;
    }
    setState(() {
      _currentPage = page;
    });
    _pageController.jumpToPage(_currentPage);
  }

  @override
  void initState() {
    _stateWords = widget.words;
    _pageController = PageController(initialPage: _currentPage);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int getPercent() {
    final double progress = _stateWords.where((element) => element.isRead,).length / (_stateWords.isEmpty ? 1 : _stateWords.length);
    return (progress * 100).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JLPT ${widget.level.name}'),
        centerTitle: false,
        backgroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('전체진도 ${getPercent()}%',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize
              ),
            ),
          ),
          const SizedBox(width: 8,),
          Consumer(
            builder: (context, ref, child) {
              var cycle = ref.watch(studyCycleNotifier);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${cycle[widget.level]}회독',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20,),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
        ),
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(65),
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        //     height: 65,
        //     child: ListView(
        //       scrollDirection: Axis.horizontal,
        //       children: [
        //         GestureDetector(
        //           onTap: () {
        //             _onChangePage(0);
        //           },
        //           child: Container(
        //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //             decoration: BoxDecoration(
        //               color: _currentPage == 0 ? Theme.of(context).colorScheme.primary : null,
        //               borderRadius: BorderRadius.circular(14),
        //             ),
        //             child: Text('단어',
        //               style: TextStyle(
        //                 color: _currentPage == 0 ? Colors.white : null,
        //                 fontWeight: FontWeight.w500,
        //                 fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
        //               ),
        //             ),
        //           ),
        //         ),
        //         const SizedBox(width: 8,),
        //         GestureDetector(
        //           onTap: () {
        //             _onChangePage(1);
        //           },
        //           child: Container(
        //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //             decoration: BoxDecoration(
        //               color: _currentPage == 1 ? Theme.of(context).colorScheme.primary : null,
        //               borderRadius: BorderRadius.circular(14),
        //             ),
        //             child: Text('문법',
        //               style: TextStyle(
        //                 color: _currentPage == 1 ? Colors.white : null,
        //                 fontWeight: FontWeight.w500,
        //                 fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ],
        //     )
        //   ),
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 21),
        child: PageView(
          controller: _pageController,
          children: [
            ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 16,),
              itemCount: (_stateWords.length / Constant.GROUP_SIZE).ceil() + 1,
              itemBuilder: (context, index) {

                if ((_stateWords.length / Constant.GROUP_SIZE).ceil() == index) {
                  return TestStatWidget(level: widget.level,);
                }
                int start = index * Constant.GROUP_SIZE;
                int end = min((index + 1) * Constant.GROUP_SIZE, _stateWords.length);

                List<Word> innerWords = _stateWords.sublist(start, end).toList();

                return Consumer(
                  builder: (context, ref, child) {

                    var recentlyViewData = ref.watch(recentlyViewNotifier);
                    bool isType =
                        recentlyViewData.level == widget.level &&
                        recentlyViewData.type?.pageIndex == _currentPage;
                    bool isRecentlyView = isType && index == recentlyViewData.index;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return StudyPage(
                            level: widget.level,
                            words: innerWords,
                            startIndex: start, endIndex: end,
                            getSeconds: getSeconds,
                          );
                        },));
                        ref.read(recentlyViewNotifier.notifier).view(
                          level: widget.level,
                          type: PracticeType.valueOfIndex(_currentPage),
                          index: index,
                        );
                      },
                      child: CustomContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        radius: BorderRadius.circular(12),
                        border: isRecentlyView ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2
                        ) : null,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('단어 ${start + 1}-$end',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: Theme.of(context).textTheme.displaySmall!.fontSize
                                  ),
                                ),
                                if (isRecentlyView)
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
                            // const SizedBox(height: 6,),
                            // Row(
                            //   children: [
                            //     Icon(Icons.check_circle,
                            //       size: Theme.of(context).textTheme.bodySmall!.fontSize,
                            //       color: Theme.of(context).colorScheme.primary,
                            //     ),
                            //     const SizedBox(width: 4,),
                            //     Text('정답률 90%',
                            //       style: TextStyle(
                            //           fontSize: Theme.of(context).textTheme.bodySmall!.fontSize
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 12,),
                            ValueListenableBuilder(
                              valueListenable: Hive.box(DBHive.JAPAN_WORDS_BOX).listenable(),
                              builder: (context, value, child) {
                                return CustomProgressBar(
                                  current: innerWords.where((word) => word.isRead).length,
                                  total: innerWords.length,
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            ListView(
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) {
                    //   return StudyPage(
                    //     // title: 'N4 단어 1-50',
                    //     level: widget.level,
                    //     startIndex: 1, endIndex: 50,
                    //   );
                    // },));
                  },
                  child: CustomContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    radius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('단어 1-50',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: Theme.of(context).textTheme.displaySmall!.fontSize
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6,),

                        Row(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                  size: Theme.of(context).textTheme.bodySmall!.fontSize,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4,),
                                Text('학습시간 2.5h',
                                  style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodySmall!.fontSize
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8,),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                  size: Theme.of(context).textTheme.bodySmall!.fontSize,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                const SizedBox(width: 4,),
                                Text('학습시간 2.5h',
                                  style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodySmall!.fontSize
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12,),
                        const CustomProgressBar(current: 25, total: 50)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16,),
                GestureDetector(
                  onTap: () => {

                  },
                  child: CustomContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    radius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('단어 51-100',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: Theme.of(context).textTheme.displaySmall!.fontSize
                              ),
                            ),
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
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                  size: Theme.of(context).textTheme.bodySmall!.fontSize,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4,),
                                Text('학습시간 2.5h',
                                  style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodySmall!.fontSize
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8,),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                  size: Theme.of(context).textTheme.bodySmall!.fontSize,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                const SizedBox(width: 4,),
                                Text('학습시간 2.5h',
                                  style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodySmall!.fontSize
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12,),
                        const CustomProgressBar(current: 1, total: 50)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
