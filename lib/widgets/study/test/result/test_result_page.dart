
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/box/question_entity_box.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/timer.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/study/test/result/test_result_detail_page.dart';

class TestResultPage extends StatefulWidget {
  const TestResultPage({super.key});

  @override
  State<TestResultPage> createState() => _TestResultPageState();
}

class _TestResultPageState extends State<TestResultPage> {

  late final PageController _pageController;
  int _currentPage = 0;

  late List<QuestionEntityBox> _results;
  bool _loading = true;

  final List<Level?> levels = [null, ...Level.values];

  _onChangePage(int page) {
    if (page == _currentPage) return;

    setState(() {
      _currentPage = page;
    });
    _pageController.jumpToPage(_currentPage,);
  }

  _loadData() {
    setState(() {
      _results = DBHive.instance.getTestResults().reversed.toList();
      _loading = false;
    });
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
    _pageController = PageController(
      initialPage: _currentPage
    );
    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('테스트 기록'),
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              height: 65,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => const SizedBox(width: 8,),
                itemCount: levels.length,
                itemBuilder: (context, index) {

                  var level = levels[index];
                  return GestureDetector(
                    onTap: () {
                      _onChangePage(index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Theme.of(context).colorScheme.primary : null,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(level == null ? '통합' : level.name,
                        style: TextStyle(
                          color: _currentPage == index ? Colors.white : null,
                          fontWeight: FontWeight.w500,
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                        ),
                      ),
                    ),
                  );
                },
              )
          ),
        ),
      ),
      body: _loading ? Center(child: CupertinoActivityIndicator()) :
      Padding(
        padding: const EdgeInsets.all(20),
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (value) {
            _onChangePage(value);
          },
          itemCount: levels.length,
          itemBuilder: (context, index) {
            List<QuestionEntityBox> list = _results.where((e) => (e.level == levels[index])).toList();
            return ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 16,),
              itemCount: list.length,
              itemBuilder: (context, index) {
                QuestionEntityBox result = list[index];

                var question = result.question;

                int totalCnt = question.length;
                int correctCnt = question.where((e) => e.isCorrect).length;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return TestResultDetailPage(question: result);
                    },));
                  },
                  child: CustomContainer(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('yyyy.MM.dd HH:mm').format(result.dateTime),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                                color: Theme.of(context).colorScheme.onPrimary
                              ),
                            ),
                            const SizedBox(height: 6,),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                      size: Theme.of(context).textTheme.bodySmall!.fontSize,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4,),
                                    Text('정답률 ${_getPercentage(totalCnt, correctCnt)}',
                                      style: TextStyle(
                                          fontSize: Theme.of(context).textTheme.bodySmall!.fontSize
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8,),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded,
                                      size: Theme.of(context).textTheme.bodySmall!.fontSize,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4,),
                                    Text(formatSeconds(result.time),
                                      style: TextStyle(
                                          fontSize: Theme.of(context).textTheme.bodySmall!.fontSize
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text('$correctCnt/$totalCnt',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: Theme.of(context).textTheme.displaySmall!.fontSize,
                            fontWeight: FontWeight.w600
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
