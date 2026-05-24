import 'package:flutter/material.dart';

import 'package:jlpt_app/component/svg_icon.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/widgets/component/record_component.dart';
import 'package:jlpt_app/widgets/component/record_row.dart';

class NextModal extends StatefulWidget {
  final int wordsLearned;
  final double studyHours;
  final VoidCallback onNextLevelTap;
  final VoidCallback onViewTestTap;

  const NextModal({
    super.key,
    required this.wordsLearned,
    required this.studyHours,
    required this.onNextLevelTap,
    required this.onViewTestTap,
  });

  @override
  State<NextModal> createState() => _NextModalState();
}

class _NextModalState extends State<NextModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));

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
                    '고생했어요!',
                    style: context.text.displayMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    '이제 다음 챕터로 넘어가볼까요?',
                    textAlign: TextAlign.center,
                    style: context.text.bodyLarge,
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
                      child: Text(
                        '다음으로 넘어가기',
                        style: context.text.bodyLarge?.copyWith(
                          color: context.colors.onPrimary,
                        ),
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
                        '조금 더 보기',
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
