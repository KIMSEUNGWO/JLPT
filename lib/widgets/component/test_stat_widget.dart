import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 35),
      child: Column(
        children: [
          Text(
            '무작위로 선정된 단어로 테스트가 진행됩니다.',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => RecordRow(dataList: [
              RecordData(title: '최근 테스트 점수', value: stats.recentScore),
              RecordData(title: '총 테스트 횟수', value: '${stats.count}회'),
            ]),
          ),
          const SizedBox(height: 14),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                '${level == null ? '통합' : level!.label} 단어 테스트 시작',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
