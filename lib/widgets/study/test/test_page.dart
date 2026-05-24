import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/app/route_args.dart';
import 'package:jlpt_app/component/test_examiner.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
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
            final testResult = await ref
                .read(testResultRepositoryProvider)
                .save(
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
    if (!mounted) return;
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
    if (_questionList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.args.level?.label ?? '통합'} ${widget.args.type.title} 테스트',
          ),
          centerTitle: false,
          backgroundColor: context.colors.surface,
        ),
        body: Center(
          child: Text('출제할 단어가 없습니다.', style: context.text.bodyLarge),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.args.level?.label ?? '통합'} ${widget.args.type.title} 테스트',
        ),
        centerTitle: false,
        backgroundColor: context.colors.surface,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: context.colors.primary, size: 12),
                const SizedBox(width: AppSpacing.xs),
                CustomTimer(controller: _timerController, getSeconds: (_) {}),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            height: 60,
            child: CustomProgressBar(
              topWidget: (current, total, _) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '진행률',
                    style: context.text.bodySmall?.copyWith(
                      color: context.feedback.textTertiary,
                    ),
                  ),
                  Text(
                    '$current/$total',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
            begin: const Offset(0.0, 2.0),
            end: Offset.zero,
          ).animate(animation),
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
              padding: const EdgeInsets.all(AppSpacing.md),
              child: GestureDetector(
                onTap: _next,
                child: CustomContainer(
                  height: 50,
                  backgroundColor: _nextBtnDisabled
                      ? context.colors.surface
                      : context.colors.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: context.colors.onPrimary,
                        size: 15,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '다음',
                        style: context.text.bodyLarge?.copyWith(
                          color: _nextBtnDisabled
                              ? context.colors.primary
                              : context.colors.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const SimpleBannerAd(width: double.infinity, height: 100),
          ],
        ),
      ),
    );
  }
}
