import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/timer.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/today_notifier.dart';
import 'package:jlpt_app/widgets/component/ads_banner.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';
import 'package:jlpt_app/widgets/study/card/widget_word_card.dart';
import 'package:jlpt_app/widgets/modal/next_modal.dart';

class StudyPage extends ConsumerStatefulWidget {

  final Level level;

  final List<Word> words;
  final int startIndex;
  final int endIndex;
  final Function(int seconds) getSeconds;

  const StudyPage({super.key, required this.level, required this.words, required this.startIndex, required this.endIndex, required this.getSeconds});


  @override
  createState() => _StudyPageState();
}

class _StudyPageState extends ConsumerState<StudyPage> {

  final TimerController _timerController = TimerController();

  late final bool isInitiallyCompleted;
  late List<Word> innerWords;
  int currentIndex = 0;

  void _showNextWord() {
    // 마지막 카드가 아닌 경우 다음 카드로 이동
    if (currentIndex < innerWords.length - 1) {
      setState(() => currentIndex++);
      return;
    }

    // 처음진입 시 100%이거나 지금 모든 단어를 읽지 않은 경우
    if (isInitiallyCompleted || !_hasAllRead()) {
      removeIsReadWord();
      setState(() => currentIndex = 0);
      return;
    }

    // 모든 단어를 읽은 경우
    _timerController.stop();
    // 축하 모달 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NextModal(
        wordsLearned: widget.words.length,
        studyHours: 2.5,
        onNextLevelTap: () {
          Navigator.of(context).pop(); // 모달 닫기
          Navigator.of(context).pop(); // StudyPage 닫기
        },
        onViewTestTap: () {
          _timerController.restart();
          Navigator.of(context).pop(); // 모달 닫기
          setState(() {
            isInitiallyCompleted = true; // 남아서 계속 단어카드를 보는 경우 더이상 모달창이 뜨지않도록 변경
            innerWords = [...widget.words];
            innerWords.shuffle();
            currentIndex = 0;
          });
        },
      ),
    );
  }

  void removeIsReadWord() {
    var unreadWords = widget.words.where((word) => !word.isRead).toList();
    setState(() {
      // 읽지 않은 단어가 없으면 모든 단어를 로드, 있으면 읽지 않은 단어만 로드
      innerWords = unreadWords.isEmpty ? widget.words : unreadWords;
      innerWords.shuffle();
    });
  }

  _select(Word selectWord) async {
    await DBHive.instance.updateWordIsReadTrue(widget.level, selectWord);
    selectWord.isRead = true;
    _showNextWord();
    ref.read(todayNotifier.notifier).plusWordCnt();
  }

  bool _hasAllRead() {
    return widget.words.every((word) => word.isRead);
  }

  @override
  void initState() {
    isInitiallyCompleted = _hasAllRead();
    removeIsReadWord();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JLPT ${widget.level.name} 단어 ${widget.startIndex + 1}-${widget.endIndex}'),
        centerTitle: false,
        backgroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(20)
            ),
            child: Row(
              children: [
                Icon(Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                  size: 12,
                ),
                const SizedBox(width: 4,),
                CustomTimer(
                  controller: _timerController,
                  getSeconds: widget.getSeconds,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20,),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              height: 60,
              child: Consumer(
                builder: (context, ref, child) {
                  int current = widget.words.where((element) => element.isRead,).length;
                  return CustomProgressBar(
                    topWidget: (current, total, percent) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '진행률',
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),
                          Text(
                            '$current/$total',
                            style: TextStyle(
                                fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      );
                    },
                    current: current,
                    total: widget.words.length,
                  );
                },
              ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 2.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: WordCardWidget(word: innerWords[currentIndex], key: ValueKey<int>(currentIndex)),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showNextWord();
                      },
                      child: CustomContainer(
                        height: 50,
                        backgroundColor: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close,
                              color: Theme.of(context).colorScheme.primary,
                              size: 15,
                            ),
                            const SizedBox(width: 8,),
                            Text('잘 모르겠음',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                fontWeight: FontWeight.w500
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 21,),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _select(innerWords[currentIndex]),
                      child: CustomContainer(
                        height: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 8,),
                            Text('이해했음',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SimpleBannerAd(width: double.infinity, height: 100,)
          ],
        ),
      ),
    );
  }
}

