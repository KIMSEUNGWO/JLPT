
import 'package:flutter/material.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question_box.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';

class TestCardWidget extends StatefulWidget {

  final Question data;
  final bool reverse;
  final Function(Question question, QuestionBox answer) selectAnswer;
  const TestCardWidget({super.key,
    required this.data,
    required this.reverse,
    required this.selectAnswer
  });

  @override
  State<TestCardWidget> createState() => _TestCardWidgetState();
}

class _TestCardWidgetState extends State<TestCardWidget> with TickerProviderStateMixin {

  QuestionBox? _myAnswer = null;

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
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomContainer(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            constraints: BoxConstraints(
              minHeight: 200,
              maxHeight: 240
            ),
            child: Center(
              child: Text(
                widget.reverse ? widget.data.question.getKorean() : widget.data.question.getJapanese(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16,),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2열
              crossAxisSpacing: 16, // 가로 간격
              mainAxisSpacing: 16, // 세로 간격
              mainAxisExtent: 50, // 각 항목의 높이
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              var answer = widget.data.examples[index];
              return GestureDetector(
                onTap: () {
                  _selectAnswer(answer);
                },
                child: CustomContainer(
                  backgroundColor: _myAnswer == answer ? Color(0xFFEAEAFF) : Colors.white,
                  border: _myAnswer == answer ? Border.all(
                    color: Theme.of(context).colorScheme.primary
                  ) : null,
                  child: Text(widget.reverse
                      ? answer.getJapanese()
                      : answer.getKorean(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
