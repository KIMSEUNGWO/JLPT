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
  // 초기 진입 시의 상태를 저장할 변수 추가
  late bool isInitiallyCompleted;

  late List<Word> innerWords;
  int currentIndex = 0;

  /// widget.words 는 1-50 단위로 read 여부와 관계없이 모두 데이터를 불러온다. 즉 데이터 변경이 일어나서는 안된다.
  /// innerWords 는 사용자에게 단어카드로 사용된다.
  ///
  /// 사용자가 '이해했음' 버튼을 누르면 read = true가 되고 innerWords 에서 제거되어야한다.
  /// 사용자가 '잘 모르겠음' 버튼을 누르면 innerWords 에서 제거되어야 한다.
  ///
  /// 모든 단어를 소진햇을 경우 아래의 조건에 따라 다르게 적용된다.
  /// 1. 아직 모든 단어를 read 하지 않은 경우
  /// 사용자가 마지막 카드까지 모두 열었지만 아직 이해하지 못한 단어가 존재했을 경우 아직 read 되지 않은 카드가 innerWords에 저장되고,
  /// 모든 단어카드가 read 될때까지 반복한다.
  ///
  /// 2. 모든 단어를 read 한 경우
  /// 모달창을 사용해서 사용자에게 다음 챕터로 이동할 것인지 물어본다.
  /// 다음 챕터로 이동할 것을 동의한다면 해당 Widget은 pop된다.
  ///
  /// 머물기를 원한다면 innerWords 에는 read 여부와 관계없이 모든 데이터가 로드된다.
  /// 이는 모든 단어카드가 read되고 다시 해당 챕터에 들어왔을 때도 동일하게 작동되어야 한다.
  ///
  void _showNextWord({Word? readWord}) {
    // 모든 단어의 현재 read 상태 확인
    bool allWordsRead = widget.words.every((word) => word.isRead);

    // 마지막 카드인 경우
    if (currentIndex >= innerWords.length - 1) {
      // 처음 진입 시 이미 100%가 아니었고, 지금 모든 단어를 읽은 경우
      if (!isInitiallyCompleted && allWordsRead) {
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
      } else {
        // 이미 100%였거나 아직 읽지 않은 단어가 있는 경우
        // 읽지 않은 단어만 또는 전체 단어를 다시 로드
        removeIsReadWord();
        setState(() => currentIndex = 0);
      }
    } else {
      // 다음 카드로 이동
      setState(() => currentIndex++);
    }
  }

// removeIsReadWord 메소드도 약간 수정
  void removeIsReadWord() {
    var unreadWords = widget.words.where((word) => !word.isRead).toList();
    setState(() {
      // 읽지 않은 단어가 없으면 모든 단어를 로드, 있으면 읽지 않은 단어만 로드
      innerWords = unreadWords.isEmpty ? [...widget.words] : unreadWords;
      innerWords.shuffle();
    });
  }

  _selectOK(int id) async {

    await DBHive.instance.updateWordIsReadTrue(widget.level, id);

    innerWords.firstWhere((e) => e.id == id).isRead = true;
    setState(() {

    });
  }


  @override
  void initState() {
    isInitiallyCompleted = widget.words.every((word) => word.isRead);
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
      body: AnimatedSwitcher(
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
                      onTap: () {
                        _selectOK(innerWords[currentIndex].id);
                        _showNextWord(readWord: innerWords[currentIndex]);
                        ref.read(todayNotifier.notifier).plusWordCnt();
                      },
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
                                  fontWeight: FontWeight.w500
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

