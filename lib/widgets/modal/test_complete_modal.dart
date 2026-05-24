import 'package:flutter/material.dart';

import 'package:jlpt_app/component/svg_icon.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/domain/timer.dart';
import 'package:jlpt_app/widgets/component/record_component.dart';
import 'package:jlpt_app/widgets/component/record_row.dart';

class TestCompleteModal extends StatefulWidget {

  final int count;
  final int time;
  final Future<void> Function() onGoToResultPage;
  final VoidCallback onBack;

  const TestCompleteModal({
    super.key,
    required this.onGoToResultPage,
    required this.onBack,
    required this.count,
    required this.time,
  });

  @override
  State<TestCompleteModal> createState() => _TestCompleteModalState();
}

class _TestCompleteModalState extends State<TestCompleteModal> with SingleTickerProviderStateMixin {
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
                    '테스트 완료',
                    style: context.text.displayMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    '수고하셨어요.\n테스트가 종료되었습니다.',
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
                        RecordData(title: '테스트 수', value: '${widget.count}'),
                        RecordData(title: '테스트 시간', value: formatSeconds(widget.time)),
                      ],
                      titleSize: context.text.bodyLarge!.fontSize,
                      valueSize: context.text.displaySmall!.fontSize,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await widget.onGoToResultPage();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: Text(
                        '결과 확인하기',
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
                        widget.onBack();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: context.colors.surfaceContainerLowest,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        '뒤로가기',
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
