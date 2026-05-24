import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jlpt_app/component/svg_icon.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/data/providers.dart';
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
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
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
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    '축하합니다!',
                    style: context.text.displayMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Consumer(
                    builder: (context, ref, child) {
                      int cycle = ref.read(studyCycleProvider.notifier).getCurrentCycle(widget.level);
                      final course = ref.watch(activeCourseProvider);
                      return Text(
                        '${course.displayName} ${widget.level.label} 단어 $cycle회독을\n성공적으로 완료했습니다.',
                        textAlign: TextAlign.center,
                        style: context.text.bodyLarge,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.secondary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: RecordRow(
                      dataList: [
                        RecordData(title: '학습단어', value: '${widget.wordsLearned}'),
                        RecordData(title: '총 학습시간', value: TodayData.formatTimeToHours(widget.studyTime)),
                      ],
                      titleSize: context.text.bodyLarge!.fontSize,
                      valueSize: context.text.displayMedium!.fontSize,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        widget.onNextLevelTap();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      child: Consumer(
                        builder: (context, ref, child) {
                          int cycle = ref.read(studyCycleProvider.notifier).getCurrentCycle(widget.level);
                          return Text(
                            '${cycle + 1}회독 시작하기',
                            style: context.text.bodyLarge?.copyWith(
                              color: context.colors.onPrimary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        widget.onViewTestTap();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: context.colors.surfaceContainerLowest,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        '단어 테스트 보기',
                        style: context.text.bodyLarge,
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
