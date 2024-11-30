
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jlpt_app/component/test_examiner.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question_box.dart';
import 'package:jlpt_app/domain/timer.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/widgets/component/ads_banner.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';
import 'package:jlpt_app/widgets/modal/TestCompleteModal.dart';
import 'package:jlpt_app/widgets/study/test/result/test_result_page.dart';
import 'package:jlpt_app/widgets/study/test/widget_test_card.dart';

class TestPage<T> extends StatefulWidget {

  final PracticeType type;
  final Level? level;
  final int count;

  const TestPage({super.key,
    required this.type,
    required this.level,
    this.count = 100,
  });


  @override
  State<TestPage<T>> createState() => _TestPageState();
}

class _TestPageState<T> extends State<TestPage<T>> {

  final TimerController _timerController = TimerController();

  bool _loading = true;
  late List<Question> _questionList;
  late List<bool> _reverseIndexList;
  int _currentIndex = 0;

  bool _nextBtnDisabled = true;

  Question? tempQuestion = null;
  QuestionBox? tempAnswer = null;

  _selectAnswer(Question question, QuestionBox answer) {
    tempQuestion = question;
    tempAnswer = answer;

    setState(() {
      _nextBtnDisabled = false;
    });
  }

  _next() async {
    if (_nextBtnDisabled) return;

    tempQuestion!.myAnswer = tempAnswer;

    setState(() {
      tempQuestion = null;
      tempAnswer = null;
      _nextBtnDisabled = true;
    });

    if (_currentIndex >= _questionList.length - 1) {
      _timerController.stop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return TestCompleteModal(
            count: _questionList.length,
            time: _timerController.getTime(),
            onGoToResultPage: () async {
              await DBHive.instance.saveTestResult(
                level: widget.level,
                type: widget.type,
                result: _questionList,
                reverses: _reverseIndexList,
                time: _timerController.getTime()
              );
              Navigator.pop(context); // 모달창 닫기
              Navigator.pop(context); // 테스트창 닫기
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TestResultPage();
              },));
            },
            onBack: () {

              Navigator.pop(context); // 모달창 닫기
              Navigator.pop(context); // 테스트창 닫기
            },
          );
        },
      );
      return;
    }
    setState(() {
      _currentIndex++;
    });

  }

  _getSeconds(int seconds) {

  }

  _setQuestion() {
    _questionList = TestExaminer.instance.getQuestions<T>(
      level: widget.level,
      count: widget.count
    );
    _questionFormShuffle();
    setState(() {
      _loading = false;
    });
  }

  _questionFormShuffle() {
    _reverseIndexList = List<bool>.generate(_questionList.length, (index) => false,);
    // 앞쪽 50%만 reverse = true로 설정
    final halfLength = (_questionList.length / 2).floor();
    for (var i = 0; i < halfLength; i++) {
      _reverseIndexList[i] = true;
    }
    _reverseIndexList.shuffle();
  }


  @override
  void initState() {
    _setQuestion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return CupertinoActivityIndicator();
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.level?.name ?? '통합'} ${widget.type.title} 테스트'),
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
                  getSeconds: _getSeconds,
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
            child: CustomProgressBar(
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
              current: _questionList.where((e) => e.myAnswer != null).length,
              total: _questionList.length,
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
        child: TestCardWidget(
          data: _questionList[_currentIndex],
          reverse: _reverseIndexList[_currentIndex],
          key: ValueKey<int>(_currentIndex),
          selectAnswer: _selectAnswer,
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: GestureDetector(
              onTap: () {
                _next();
              },
              child: CustomContainer(
                height: 50,
                backgroundColor: _nextBtnDisabled ? Colors.white : Theme.of(context).colorScheme.primary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 8,),
                    Text('다음',
                      style: TextStyle(
                        color: _nextBtnDisabled ? Theme.of(context).colorScheme.primary : Colors.white,
                        fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SimpleBannerAd(width: double.infinity, height: 100,)
        ],
      ),
    );
  }
}
