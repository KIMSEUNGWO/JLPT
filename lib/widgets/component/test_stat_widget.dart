

import 'package:flutter/material.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/box/question_entity_box.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/record_component.dart';
import 'package:jlpt_app/widgets/component/record_row.dart';
import 'package:jlpt_app/widgets/modal/test_start_modal.dart';

class TestStatWidget extends StatefulWidget {

  final Level level;
  const TestStatWidget({super.key, required this.level});

  @override
  State<TestStatWidget> createState() => _TestStatWidgetState();
}

class _TestStatWidgetState extends State<TestStatWidget> {

  late List<QuestionEntityBox> list;

  String _recentlyScore() {
    if (list.isEmpty) return '0%';
    var first = list.first.question;
    int correctCnt = first.where((e) => e.question.getJapanese() == e.myAnswer?.getJapanese()).length;
    return _getPercentage(first.length, correctCnt);
  }
  String _testCnt() {
    return '${list.length}회';
  }
  String _getPercentage(int total, int correct) {
    if (total == 0) return '0%';

    // 소수점 1자리까지 계산 (100을 곱하여 퍼센트로 변환)
    int percentage = ((correct / total) * 100).ceil();

    // 100%를 넘지 않도록 제한
    percentage = percentage.clamp(0, 100);

    return '$percentage%';
  }

  @override
  void initState() {
    list = DBHive.instance.getTestResults();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 35),
      child: Column(
        children: [
          Text('무작위로 선정된 100개의 단어로 테스트가 진행됩니다.',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
              fontWeight: FontWeight.w400
            ),
          ),
          const SizedBox(height: 14,),
          RecordRow(
            dataList: [
              RecordData(title: '최근 테스트 점수', value: _recentlyScore()),
              RecordData(title: '총 테스트 횟수', value: _testCnt()),
              // RecordData(title: '오답노트', value: '12개'),
            ],
          ),
          const SizedBox(height: 14,),
          SizedBox(
            width: double.infinity,
            height: 35,
            child: TextButton(
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return TestStartModal(
                    type: PracticeType.WORD,
                    level: widget.level,
                  );
                },);
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                )
              ),
              child: Text('${widget.level.name} 단어 테스트 시작',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
