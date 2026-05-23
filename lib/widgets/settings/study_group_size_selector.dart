import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/study_group_size.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_group_size_selector.g.dart';

final studyGroupSizeProvider = Provider<int>(
  (ref) => ref.watch(_studyGroupSizeControllerProvider),
);

@Riverpod(keepAlive: true)
class _StudyGroupSizeController extends _$StudyGroupSizeController {
  @override
  int build() => LocalStorage.instance.getStudyGroupSize();

  void setGroupSize(int value) {
    if (!studyGroupSizeOptions.contains(value) || state == value) return;
    state = value;
    unawaited(LocalStorage.instance.saveStudyGroupSize(value));
  }
}

class StudyGroupSizeSelector extends ConsumerWidget {
  const StudyGroupSizeSelector({super.key});

  Future<void> _showPicker(
    BuildContext context,
    WidgetRef ref,
    int selected,
  ) async {
    final controller = ref.read(_studyGroupSizeControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(
          '단어 묶음 크기',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        message: Text(
          '한 묶음에 담을 단어 수를 선택하세요',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        actions: [
          for (final size in studyGroupSizeOptions)
            CupertinoActionSheetAction(
              isDefaultAction: size == selected,
              onPressed: () {
                controller.setGroupSize(size);
                Navigator.pop(ctx);
              },
              child: Text(
                '$size개씩',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: size == selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            '취소',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(studyGroupSizeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showPicker(context, ref, selected),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.view_module_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '단어 묶음',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '학습 리스트에서 한 묶음에 담을 단어 수를 정합니다',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$selected개씩',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
