import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/record_component.dart';
import 'package:jlpt_app/widgets/component/record_row.dart';
import 'package:jlpt_app/widgets/modal/test_start_modal.dart';

class TestStatWidget extends ConsumerWidget {
  final Level? level;

  const TestStatWidget({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(testStatsByLevelProvider(level));

    return CustomContainer(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.xxxl,
      ),
      child: Column(
        children: [
          Text(
            '무작위로 선정된 단어로 테스트가 진행됩니다.',
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => RecordRow(dataList: [
              RecordData(title: '최근 테스트 점수', value: stats.recentScore),
              RecordData(title: '총 테스트 횟수', value: '${stats.count}회'),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 35,
            child: TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => TestStartModal(
                  type: PracticeType.WORD,
                  level: level,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                '${level == null ? '통합' : level!.label} 단어 테스트 시작',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
