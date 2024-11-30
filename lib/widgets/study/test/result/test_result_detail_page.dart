

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jlpt_app/component/chart/Data.dart';
import 'package:jlpt_app/component/chart/NPieChart2.dart';
import 'package:jlpt_app/component/chart/PieChart.dart';
import 'package:jlpt_app/domain/box/question_entity_box.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/timer.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/record_component.dart';
import 'package:jlpt_app/widgets/component/record_row.dart';

class TestResultDetailPage extends StatefulWidget {
  final QuestionEntityBox question;

  const TestResultDetailPage({super.key, required this.question});

  @override
  State<TestResultDetailPage> createState() => _TestResultDetailPageState();
}

class _TestResultDetailPageState extends State<TestResultDetailPage> {

  late List<Question> _question;
  bool _onlyIncorrect = false;

  final Color _correctColor = Color(0xFF2E7D32);
  final Color _correctBackgroundColor = Color(0xFFE8F5E9);
  final Color _incorrectColor = Color(0xFFC62828);
  final Color _incorrectBackgroundColor = Color(0xFFFFEBEE);


  _toggleOnlyIncorrect() {
    _onlyIncorrect = !_onlyIncorrect;

    if (_onlyIncorrect) {
      _question = widget.question.question.where((e) => e.question.getJapanese() != e.myAnswer?.getJapanese()).toList();
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
  int correctCnt = widget.question.question.where((e) => e.question.getJapanese() == e.myAnswer?.getJapanese()).length;
  int totalCnt = widget.question.question.length;
  
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.question.level == null ? '통합' : widget.question.level!.name} 테스트 기록'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            CustomContainer(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('yyyy.MM.dd HH:mm').format(widget.question.dateTime),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 21,),
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
                              Text('$correctCnt',
                                style: TextStyle(
                                  fontFamily: 'Tmoney',
                                  fontWeight: FontWeight.w600,
                                  fontSize: Theme.of(context).textTheme.displayMedium!.fontSize,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              Text('/$totalCnt',
                                style: TextStyle(
                                  fontFamily: 'Tmoney',
                                  fontWeight: FontWeight.w600,
                                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('당신의 점수는',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text('합격 수준입니다!',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    margin: EdgeInsets.symmetric(vertical: 21),
                    color: const Color(0xFFE9ECEF),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FD),
                      borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 26,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('문제 리뷰',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleOnlyIncorrect,
                    child: CustomContainer(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      backgroundColor: _onlyIncorrect ? Theme.of(context).colorScheme.primary : Colors.white,
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt_rounded,
                            size: Theme.of(context).textTheme.bodySmall!.fontSize,
                            color: _onlyIncorrect ? Colors.white : null,
                          ),
                          const SizedBox(width: 4,),
                          Text('틀린문제만',
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                              color: _onlyIncorrect ? Colors.white : null
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12,),

            ..._question.map((e) {

              bool isCorrect = e.question.getJapanese() == e.myAnswer?.getJapanese();

              return CustomContainer(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.reverse ? e.question.getKorean() : e.question.getJapanese(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: Theme.of(context).textTheme.displayMedium!.fontSize,
                          ),
                        ),

                        isCorrect ? _correct(context) : _incorrect(context),
                      ],
                    ),
                    const SizedBox(height: 6,),
                    if (!e.reverse && e.question is Word)
                      Text((e.question as Word).hiragana,
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                        ),
                      ),

                    const SizedBox(height: 21,),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text('선택한 답',
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8,),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: isCorrect ? _correctBackgroundColor : _incorrectBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(e.reverse ? e.myAnswer!.getJapanese() : e.myAnswer!.getKorean(),
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                    fontWeight: FontWeight.w500,
                                    color: isCorrect ? _correctColor : _incorrectColor
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12,),
                        if (!isCorrect)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text('정답',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8,),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: _correctBackgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(e.reverse ? e.question.getJapanese() : e.question.getKorean(),
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                      fontWeight: FontWeight.w500,
                                      color: _correctColor,
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
            })
          ],
        ),
      )
    );
  }

  Widget _correct(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _correctBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
            color: _correctColor,
            size: Theme.of(context).textTheme.bodyMedium!.fontSize,
          ),
          const SizedBox(width: 4,),
          Text('정답',
            style: TextStyle(
              color: _correctColor,
              fontWeight: FontWeight.w500,
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            ),
          )
        ],
      ),
    );
  }

  Widget _incorrect(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _incorrectBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined,
            color: _incorrectColor,
            size: Theme.of(context).textTheme.bodyMedium!.fontSize,
          ),
          const SizedBox(width: 4,),
          Text('오답',
            style: TextStyle(
              color: _incorrectColor,
              fontWeight: FontWeight.w500,
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            ),
          )
        ],
      ),
    );
  }

  Widget _gridWidget({required Color backgroundColor, required Color textColor, required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text('선택한 답',
            style: TextStyle(
              color: textColor,

            ),
          ),
        )
      ],
    );
  }
}


