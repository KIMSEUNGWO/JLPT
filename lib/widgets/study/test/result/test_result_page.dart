import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/app/route_args.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jlpt_app/core/app_utils.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/box/question_entity_box.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/timer.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';

final _testResultsProvider = FutureProvider<List<QuestionEntityBox>>((ref) {
  return ref.read(testResultRepositoryProvider).getAll();
});

class TestResultPage extends ConsumerStatefulWidget {
  final QuestionEntityBox? result;

  const TestResultPage({super.key, this.result});

  @override
  ConsumerState<TestResultPage> createState() => _TestResultPageState();
}

class _TestResultPageState extends ConsumerState<TestResultPage> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _openedInitialResult = false;

  final List<Level?> levels = [null, ...Level.values];

  void _onChangePage(int page) {
    if (page == _currentPage) return;
    setState(() => _currentPage = page);
    _pageController.jumpToPage(_currentPage);
  }

  void _fastMove() {
    if (widget.result == null || _openedInitialResult) return;
    _openedInitialResult = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final page = levels.indexOf(widget.result!.level);
      _onChangePage(page);
      context.push(
        '${AppRoutes.testResults}/${AppRoutes.testResultDetail}',
        extra: TestResultDetailArgs(question: widget.result!),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(_testResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('테스트 기록'),
        centerTitle: false,
        shape: kAppBarShape,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            height: 65,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, _s) => const SizedBox(width: 8),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                return GestureDetector(
                  onTap: () => _onChangePage(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      level == null ? '통합' : level.name,
                      style: TextStyle(
                        color: _currentPage == index ? Colors.white : null,
                        fontWeight: FontWeight.w500,
                        fontSize:
                            Theme.of(context).textTheme.bodyLarge!.fontSize,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: resultsAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (_, __) => const Center(child: Text('데이터를 불러올 수 없습니다')),
        data: (results) {
          _fastMove();
          return Padding(
            padding: const EdgeInsets.all(20),
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _onChangePage,
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final list = results
                    .where((e) => e.level == levels[index])
                    .toList();
                return ListView.separated(
                  separatorBuilder: (_, _s) => const SizedBox(height: 16),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final r = list[i];
                    final total = r.question.length;
                    final correct =
                        r.question.where((q) => q.isCorrect).length;
                    return GestureDetector(
                      onTap: () => context.push(
                        '${AppRoutes.testResults}/${AppRoutes.testResultDetail}',
                        extra: TestResultDetailArgs(question: r),
                      ),
                      child: CustomContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('yyyy.MM.dd HH:mm')
                                      .format(r.dateTime),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .fontSize,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(children: [
                                  Row(children: [
                                    Icon(Icons.check_circle,
                                        size: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .fontSize,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    const SizedBox(width: 4),
                                    Text(
                                        '정답률 ${correctRatePercent(correct, total)}',
                                        style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .fontSize)),
                                  ]),
                                  const SizedBox(width: 8),
                                  Row(children: [
                                    Icon(Icons.access_time_rounded,
                                        size: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .fontSize,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    const SizedBox(width: 4),
                                    Text(formatSeconds(r.time),
                                        style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .fontSize)),
                                  ]),
                                ]),
                              ],
                            ),
                            Text(
                              '$correct/$total',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .fontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
