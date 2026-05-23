import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/example_sentence.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/widgets/component/audio_button.dart';

/// 카드 상세 박스 안에서 단어의 예문을 보여주는 섹션.
///
/// 한자 박스와 동일한 스타일의 자체 박스를 소유 — 두 정보가 시각적으로 명확히
/// 분리된다. 음성 재생은 단어 발음용 [Speaker] 와 충돌하지 않도록 각 예문 타일이
/// 자체 [AudioWaveAnimation] 을 소유한다.
class ExampleSentenceSection extends ConsumerWidget {
  const ExampleSentenceSection({super.key, required this.word});

  final Word word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(exampleSentencesByWordProvider(word.id));
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 21),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: async.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => Text(
          '예문을 불러올 수 없습니다.',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            color: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
        data: (examples) {
          if (examples.isEmpty) {
            return Text(
              '예문 정보가 없습니다.',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '예문',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                ),
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < examples.length; i++) ...[
                _ExampleSentenceTile(example: examples[i]),
                if (i < examples.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ExampleSentenceTile extends StatelessWidget {
  const _ExampleSentenceTile({required this.example});

  final ExampleSentence example;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 일본어 문장 + 음성 버튼이 같은 row. 문장이 길면 Expanded 가
        // 줄바꿈을 허용하고, 버튼은 첫 줄 베이스라인에 고정된다.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                example.sentence,
                style: TextStyle(
                  fontSize: theme.textTheme.bodyLarge!.fontSize,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // compact + title 미지정 → wave 4-bar 만 남는 한층 작은 pill.
            AudioWaveAnimation(
              word: example.sentence,
              compact: true,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          example.translation,
          style: TextStyle(
            fontSize: theme.textTheme.bodyMedium!.fontSize,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
