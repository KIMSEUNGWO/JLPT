import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jlpt_app/component/snack_bar.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/data/sync/update_service.dart';

/// 원격 업데이트가 가능한 상태에서만 띄우는 모달. [UpdateService.applyUpdate] 호출.
class UpdateModal extends ConsumerStatefulWidget {
  const UpdateModal({super.key, required this.plan});
  final UpdatePlan plan;

  @override
  ConsumerState<UpdateModal> createState() => _UpdateModalState();
}

class _UpdateModalState extends ConsumerState<UpdateModal> {
  UpdateStage? _stage;
  bool _running = false;

  Future<void> _start() async {
    if (_running) return;
    setState(() => _running = true);
    try {
      await ref
          .read(updateServiceProvider)
          .applyUpdate(
            widget.plan,
            onStage: (s) {
              if (!mounted) return;
              setState(() => _stage = s);
            },
          );
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _running = false);
      CustomSnackBar.instance.message(context, '업데이트 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '업데이트 가능',
              style: context.text.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: context.text.titleMedium!.fontSize,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('새 버전: ${widget.plan.version}'),
            const SizedBox(height: AppSpacing.xs),
            Text('예상 크기: ${_formatBytes(widget.plan.estimatedBytes)}'),
            const SizedBox(height: AppSpacing.xxl),
            _StageIndicator(stage: _stage),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _running
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: context.colors.surfaceContainerLowest,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text('다음에'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: _running ? null : _start,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(_running ? '진행 중…' : '지금 업데이트'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '계산 중';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(1024)).floor().clamp(0, suffixes.length - 1);
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }
}

class _StageIndicator extends StatelessWidget {
  const _StageIndicator({required this.stage});
  final UpdateStage? stage;

  static const _labels = <UpdateStage, String>{
    UpdateStage.fetching: '다운로드 중',
    UpdateStage.validating: '검증 중',
    UpdateStage.persistingFiles: '파일 저장',
    UpdateStage.persistingDb: 'DB 적용',
    UpdateStage.done: '완료',
  };

  @override
  Widget build(BuildContext context) {
    final stages = UpdateStage.values;
    final current = stage;
    final currentIndex = current == null ? -1 : stages.indexOf(current);

    return Column(
      children: [
        if (current == UpdateStage.done)
          Icon(Icons.check_circle, color: context.feedback.correctText, size: 48)
        else if (current != null)
          const CircularProgressIndicator()
        else
          const Icon(Icons.cloud_download_outlined, size: 48),
        const SizedBox(height: AppSpacing.sm),
        Text(
          current == null ? '대기' : (_labels[current] ?? ''),
          style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(stages.length, (i) {
            final active = i <= currentIndex;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: active
                    ? context.colors.primary
                    : context.colors.outline,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}
