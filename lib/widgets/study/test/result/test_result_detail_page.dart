import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:jlpt_app/component/chart/pie_chart.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/domain/box/question_entity_box.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/timer.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/record_component.dart';
import 'package:jlpt_app/widgets/component/record_row.dart';


enum PrintTestResult {

  EXCELLENT('완벽한 실력입니다!'),  // 90%+ (완벽한 실력!)
  GREAT('합격 수준입니다!'),      // 80%+ (합격 수준!)
  GOOD('조금 더 노력이 필요합니다!'),       // 70%+ (조금만 더!)
  FAIR('연습이 필요합니다!'),       // 60%+ (연습 필요!)
  RETRY('다시 도전해보세요!')       // 60% 미만 (다시 도전!)
  ;
  final String text;

  const PrintTestResult(this.text);

  static String getText(int total, int correctCnt) {
    double percent = (correctCnt.toDouble() / total.toDouble()) * 100;
    return switch(percent) {
      >= 90 => PrintTestResult.EXCELLENT,
      >= 80 => PrintTestResult.GREAT,
      >= 70 => PrintTestResult.GOOD,
      >= 60 => PrintTestResult.FAIR,
      _ => PrintTestResult.RETRY
    }.text;
  }

}
class TestResultDetailPage extends StatefulWidget {
  final QuestionEntityBox question;

  const TestResultDetailPage({super.key, required this.question});

  @override
  State<TestResultDetailPage> createState() => _TestResultDetailPageState();
}

class _TestResultDetailPageState extends State<TestResultDetailPage> {

  late List<Question> _question;
  bool _onlyIncorrect = false;

  _toggleOnlyIncorrect() {
    _onlyIncorrect = !_onlyIncorrect;

    if (_onlyIncorrect) {
      _question = widget.question.question.where((e) => !e.isCorrect).toList();
    } else {
      _question = widget.question.question;
    }
    setState(() {});
  }
  _init() {
    _question = widget.question.question;
  }
  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final feedback = context.feedback;
    final correctColor = feedback.correctText;
    final correctBg = feedback.correctBackground;
    final incorrectColor = feedback.incorrectText;
    final incorrectBg = feedback.incorrectBackground;
    int correctCnt = widget.question.question.where((e) => e.isCorrect).length;
    int totalCnt = widget.question.question.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.question.level == null ? '통합' : widget.question.level!.label} 테스트 기록'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ListView(
          children: [
            CustomContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('yyyy.MM.dd HH:mm').format(widget.question.dateTime),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      PieChart(
                        radius: 40,
                        strokeWidth: 10,
                        currentSize: correctCnt.toDouble(),
                        totalSize: totalCnt.toDouble(),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$correctCnt',
                                style: context.scoreText.copyWith(
                                  fontSize: context.text.displayMedium!.fontSize,
                                ),
                              ),
                              Text(
                                '/$totalCnt',
                                style: context.scoreText.copyWith(
                                  fontSize: context.text.bodyLarge!.fontSize,
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '당신의 점수는',
                            style: context.text.bodyMedium?.copyWith(
                              color: context.colors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            PrintTestResult.getText(totalCnt, correctCnt),
                            style: context.text.bodyLarge?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    color: context.colors.outline,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.secondary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: RecordRow(dataList: [
                      RecordData(title: '소요시간', value: formatSeconds(widget.question.time)),
                      RecordData(title: '맞은 문제', value: '$correctCnt개'),
                      RecordData(title: '틀린 문제', value: '${totalCnt - correctCnt}개'),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '문제 리뷰',
                    style: context.text.bodyLarge?.copyWith(
                      color: context.colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleOnlyIncorrect,
                    child: CustomContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      backgroundColor: _onlyIncorrect
                          ? context.colors.primary
                          : context.colors.surface,
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_alt_rounded,
                            size: context.text.bodySmall!.fontSize,
                            color: _onlyIncorrect
                                ? context.colors.onPrimary
                                : context.colors.onSurface,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '틀린문제만',
                            style: context.text.bodySmall?.copyWith(
                              color: _onlyIncorrect
                                  ? context.colors.onPrimary
                                  : context.colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            ..._question.map((e) {

              bool isCorrect = e.isCorrect;

              return CustomContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.reverse ? e.question.getMeaning() : e.question.getTerm(),
                          style: context.text.displayMedium,
                        ),

                        isCorrect
                            ? _correct(context, correctColor, correctBg)
                            : _incorrect(context, incorrectColor, incorrectBg),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (!e.reverse && e.question is Word)
                      Text(
                        (e.question as Word).reading ?? '',
                        style: context.text.bodyLarge,
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: AppSpacing.xs),
                                child: Text(
                                  '선택한 답',
                                  style: context.text.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: isCorrect ? correctBg : incorrectBg,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  e.reverse ? e.myAnswer!.getTerm() : e.myAnswer!.getMeaning(),
                                  style: context.text.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: isCorrect ? correctColor : incorrectColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        if (!isCorrect)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                                  child: Text(
                                    '정답',
                                    style: context.text.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: correctBg,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    e.reverse ? e.question.getTerm() : e.question.getMeaning(),
                                    style: context.text.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: correctColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _correct(BuildContext context, Color color, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: color,
            size: context.text.bodyMedium!.fontSize,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '정답',
            style: context.text.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _incorrect(BuildContext context, Color color, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            color: color,
            size: context.text.bodyMedium!.fontSize,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '오답',
            style: context.text.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
