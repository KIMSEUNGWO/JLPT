import 'package:jlpt_app/widgets/component/recently_viewed_badge.dart';
import 'package:jlpt_app/core/app_utils.dart';
import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/core/theme/app_colors.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/constant.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/recently_view_notifier.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/notifier/timer_notifier.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';
import 'package:jlpt_app/widgets/component/test_stat_widget.dart';
import 'package:jlpt_app/widgets/modal/congratulations_modal.dart';

class StudyListPage extends ConsumerStatefulWidget {
  final Level level;
  final List<Word> words;

  const StudyListPage({super.key, required this.level, required this.words});

  @override
  createState() => _StudyListPageState();
}

class _StudyListPageState extends ConsumerState<StudyListPage> {
  late final List<Word> _stateWords;

  void _wordsInitial() {
    setState(() {
      for (var e in _stateWords) {
        e.isRead = false;
      }
    });
  }

  void getSeconds(int seconds) {
    ref.read(timerProvider.notifier).setTimer(widget.level, seconds);

    final allRead = _stateWords.every((element) => element.isRead);
    if (allRead) {
      showDialog(
        context: context,
        builder: (context) => CongratulationsModal(
          level: widget.level,
          wordsLearned: _stateWords.length,
          studyTime: ref.read(timerProvider.notifier).getLevelTime(widget.level),
          onNextLevelTap: () async {
            Navigator.of(context).pop();
            _wordsInitial();
            await ref.read(wordRepositoryProvider).resetReadFor(widget.level);
            ref.read(studyCycleProvider.notifier).cyclePlus(widget.level);
          },
          onViewTestTap: () async {
            Navigator.of(context).pop();
            _wordsInitial();
            await ref.read(wordRepositoryProvider).resetReadFor(widget.level);
            ref.read(studyCycleProvider.notifier).cyclePlus(widget.level);
          },
        ),
      );
    }
  }

  @override
  void initState() {
    _stateWords = widget.words;
    super.initState();
  }

  int _getPercent() {
    final double progress = _stateWords.where((e) => e.isRead).length /
        (_stateWords.isEmpty ? 1 : _stateWords.length);
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
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '전체진도 ${_getPercent()}%',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, child) {
              final cycle = ref.watch(studyCycleProvider);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${cycle[widget.level]}회독',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
        ],
        shape: kAppBarShape,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 21),
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemCount: (_stateWords.length / Constant.GROUP_SIZE).ceil() + 1,
          itemBuilder: (context, index) {
            if ((_stateWords.length / Constant.GROUP_SIZE).ceil() == index) {
              return TestStatWidget(level: widget.level);
            }

            final int start = index * Constant.GROUP_SIZE;
            final int end = min((index + 1) * Constant.GROUP_SIZE, _stateWords.length);
            final List<Word> innerWords = _stateWords.sublist(start, end);

            return Consumer(
              builder: (context, ref, child) {
                final recentlyViewData = ref.watch(recentlyViewProvider);
                final isRecentlyView = recentlyViewData.level == widget.level &&
                    recentlyViewData.type == PracticeType.WORD &&
                    recentlyViewData.index == index;

                return GestureDetector(
                  onTap: () {
                    context.push(AppRoutes.studyGroupFull(widget.level.name), extra: {
                      'level': widget.level,
                      'words': innerWords,
                      'startIndex': start,
                      'endIndex': end,
                      'getSeconds': getSeconds,
                    });
                    ref.read(recentlyViewProvider.notifier).view(
                      level: widget.level,
                      type: PracticeType.WORD,
                      index: index,
                    );
                  },
                  child: CustomContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    radius: BorderRadius.circular(12),
                    border: isRecentlyView
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : null,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '단어 ${start + 1}-$end',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: Theme.of(context).textTheme.displaySmall!.fontSize,
                              ),
                            ),
                            if (isRecentlyView)
                              const RecentlyViewedBadge(),
                          ],
                        ),
                        const SizedBox(height: 12),
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
      ),
    );
  }
}
