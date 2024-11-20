import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/component/svg_icon.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/notifier/entity/today.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/widgets/component/record_component.dart';
import 'package:jlpt_app/widgets/component/record_row.dart';

class CongratulationsModal extends StatefulWidget {

  final Level level;
  final int wordsLearned;
  final int studyTime;
  final VoidCallback onNextLevelTap;
  final VoidCallback onViewTestTap;

  const CongratulationsModal({
    super.key,
    required this.wordsLearned,
    required this.studyTime,
    required this.onNextLevelTap,
    required this.onViewTestTap,
    required this.level,
  });

  @override
  State<CongratulationsModal> createState() => _CongratulationsModalState();
}

class _CongratulationsModalState extends State<CongratulationsModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화 (1초 동안)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 모달 슬라이드 애니메이션 (아래에서 위로)
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // 아이콘 바운스 애니메이션
    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));

    // 애니메이션 시작
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    Future(() {

    },);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 아이콘 애니메이션
                  Transform.scale(
                    scale: _iconAnimation.value,
                    child: SvgIcon.asset(
                      sIcon: SIcon.circleCheck,
                      style: SvgIconStyle(
                          width: 100,
                          height: 100,
                          color: Theme.of(context).colorScheme.primary
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('축하합니다!',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.displayMedium!.fontSize,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Consumer(
                    builder: (context, ref, child) {
                      int cycle = ref.read(studyCycleNotifier.notifier).getCurrentCycle(widget.level);
                      return Text(
                        'JLPT ${widget.level.name} 단어 $cycle회독을\n성공적으로 완료했습니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RecordRow(
                      dataList: [
                        RecordData(title: '학습단어', value: '${widget.wordsLearned}'),
                        RecordData(title: '총 학습시간', value: TodayData.formatTimeToHours(widget.studyTime)),
                      ],
                      titleSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                      valueSize: Theme.of(context).textTheme.displayMedium!.fontSize,
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        widget.onNextLevelTap();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Consumer(
                        builder: (context, ref, child) {
                          int cycle = ref.read(studyCycleNotifier.notifier).getCurrentCycle(widget.level);
                          return Text('${cycle + 1}회독 시작하기',
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        widget.onViewTestTap();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F3F5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('단어 테스트 보기',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
