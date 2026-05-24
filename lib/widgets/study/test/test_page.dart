import 'package:jlpt_app/core/app_utils.dart';
import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/app/route_args.dart';
import 'package:jlpt_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/component/test_examiner.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question_box.dart';
import 'package:jlpt_app/domain/timer.dart';
import 'package:jlpt_app/widgets/component/ads_banner.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/custom_progressbar.dart';
import 'package:jlpt_app/widgets/modal/test_complete_modal.dart';
import 'package:jlpt_app/widgets/study/test/widget_test_card.dart';

class TestPage extends ConsumerStatefulWidget {
  final TestArgs args;

  const TestPage({super.key, required this.args});

  @override
  ConsumerState<TestPage> createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestPage> {
  final TimerController _timerController = TimerController();

  bool _loading = true;
  late List<Question> _questionList;
  late List<bool> _reverseIndexList;
  int _currentIndex = 0;
  bool _nextBtnDisabled = true;

  Question? tempQuestion;
  QuestionBox? tempAnswer;

  void _selectAnswer(Question question, QuestionBox answer) {
    tempQuestion = question;
    tempAnswer = answer;
    setState(() => _nextBtnDisabled = false);
  }

  Future<void> _next() async {
    if (_nextBtnDisabled) return;

    tempQuestion!.myAnswer = tempAnswer;
    setState(() {
      tempQuestion = null;
      tempAnswer = null;
      _nextBtnDisabled = true;
    });

    if (_currentIndex >= _questionList.length - 1) {
      _timerController.stop();
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => TestCompleteModal(
          count: _questionList.length,
          time: _timerController.getTime(),
          onGoToResultPage: () async {
            final router = GoRouter.of(context);
            final testResult =
                await ref.read(testResultRepositoryProvider).save(
                      level: widget.args.level,
                      type: widget.args.type,
                      questions: _questionList,
                      reverses: _reverseIndexList,
                      time: _timerController.getTime(),
                    );
            if (!mounted) return;
            router.pop(); // 모달 닫기
            router.pop(); // 테스트 페이지 닫기
            await router.push(
              AppRoutes.testResults,
              extra: TestResultsArgs(result: testResult),
            );
          },
          onBack: () {
            context.pop(); // 모달 닫기
            context.pop(); // 테스트 페이지 닫기
          },
        ),
      );
      return;
    }
    setState(() => _currentIndex++);
  }

  Future<void> _setQuestion() async {
    final wordsByLevel = await ref.read(wordRepositoryProvider).getAllByLevel();
    final questions = TestExaminer.instance.getWordQuestions(
      wordsByLevel: wordsByLevel,
      level: widget.args.level,
      count: widget.args.mount,
    );
    _reverseIndexList = List<bool>.generate(questions.length, (_) => false);
    final half = (questions.length / 2).floor();
    for (var i = 0; i < half; i++) {
      _reverseIndexList[i] = true;
    }
    _reverseIndexList.shuffle();
    setState(() {
      _questionList = questions;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _setQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const CupertinoActivityIndicator();
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.args.level?.label ?? '통합'} ${widget.args.type.title} 테스트'),
        centerTitle: false,
        backgroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Icon(Icons.access_time,
                  color: Theme.of(context).colorScheme.primary, size: 12),
              const SizedBox(width: 4),
              CustomTimer(controller: _timerController, getSeconds: (_) {}),
            ]),
          ),
          const SizedBox(width: 20),
        ],
        shape: kAppBarShape,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            height: 60,
            child: CustomProgressBar(
              topWidget: (current, total, _) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('진행률',
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodySmall!.fontSize,
                          color: Theme.of(context).colorScheme.onTertiary)),
                  Text('$current/$total',
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.bodySmall!.fontSize,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              current: _questionList.where((e) => e.myAnswer != null).length,
              total: _questionList.length,
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0.0, 2.0), end: Offset.zero)
              .animate(animation),
          child: child,
        ),
        child: SingleChildScrollView(
          child: TestCardWidget(
            data: _questionList[_currentIndex],
            reverse: _reverseIndexList[_currentIndex],
            key: ValueKey<int>(_currentIndex),
            selectAnswer: _selectAnswer,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: GestureDetector(
                onTap: _next,
                child: CustomContainer(
                  height: 50,
                  backgroundColor: _nextBtnDisabled
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 15),
                      const SizedBox(width: 8),
                      Text(
                        '다음',
                        style: TextStyle(
                          color: _nextBtnDisabled
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                          fontSize:
                              Theme.of(context).textTheme.bodyLarge!.fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const SimpleBannerAd(width: double.infinity, height: 100),
          ],
        ),
      ),
    );
  }
}
