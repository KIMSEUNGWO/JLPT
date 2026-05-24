import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question_box.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';

class TestCardWidget extends StatefulWidget {
  final Question data;
  final bool reverse;
  final Function(Question question, QuestionBox answer) selectAnswer;
  const TestCardWidget({
    super.key,
    required this.data,
    required this.reverse,
    required this.selectAnswer,
  });

  @override
  State<TestCardWidget> createState() => _TestCardWidgetState();
}

class _TestCardWidgetState extends State<TestCardWidget>
    with TickerProviderStateMixin {
  QuestionBox? _myAnswer;

  _selectAnswer(QuestionBox answer) {
    if (answer == _myAnswer) return;
    setState(() {
      _myAnswer = answer;
    });
    widget.selectAnswer(widget.data, _myAnswer!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.key,
      margin: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomContainer(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
            constraints: const BoxConstraints(minHeight: 200, maxHeight: 240),
            child: Center(
              child: Text(
                widget.reverse
                    ? widget.data.question.getMeaning()
                    : widget.data.question.getTerm(),
                style: context.text.headlineLarge,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2열
              crossAxisSpacing: AppSpacing.lg, // 가로 간격
              mainAxisSpacing: AppSpacing.lg, // 세로 간격
              mainAxisExtent: 50, // 각 항목의 높이
            ),
            itemCount: widget.data.examples.length,
            itemBuilder: (context, index) {
              final answer = widget.data.examples[index];
              final selected = _myAnswer == answer;
              return GestureDetector(
                onTap: () {
                  _selectAnswer(answer);
                },
                child: CustomContainer(
                  backgroundColor: selected
                      ? context.colors.primaryContainer
                      : context.colors.surface,
                  border: selected
                      ? Border.all(color: context.colors.primary)
                      : null,
                  child: Text(
                    widget.reverse ? answer.getMeaning() : answer.getTerm(),
                    textAlign: TextAlign.center,
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
