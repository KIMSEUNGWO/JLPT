import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/widgets/study/card/widget_chinese_char.dart';
import 'package:jlpt_app/widgets/study/card/widget_example_sentence.dart';

/// 학습 카드 펼침 상태의 상세 영역.
///
/// 예문 박스와 한자 박스를 **별개 컨테이너** 로 나란히 렌더링한다.
/// 두 박스는 동일한 스타일이지만 시각적으로 명확히 분리된다.
class WordCardDetailWidget extends StatelessWidget {
  final Word word;

  const WordCardDetailWidget({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExampleSentenceSection(word: word),
        const SizedBox(height: AppSpacing.md),
        _ChineseCharSection(word: word),
      ],
    );
  }
}

class _ChineseCharSection extends ConsumerWidget {
  const _ChineseCharSection({required this.word});

  final Word word;

  List<ChineseChar> _findChars(Map<String, ChineseChar> map, String text) =>
      text.characters
          .map((c) => map[c])
          .whereType<ChineseChar>()
          .toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(activeCourseProvider);
    // 문자(한자) 모듈이 없는 코스는 섹션 자체를 그리지 않는다.
    if (!course.hasCharacterModule) return const SizedBox.shrink();
    final cacheAsync = ref.watch(chineseCharCacheProvider);
    final moduleLabel = course.characterModuleLabel ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: context.colors.secondary,
      ),
      child: cacheAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => Text('$moduleLabel 정보를 불러올 수 없습니다.'),
        data: (charMap) {
          final chars = _findChars(charMap, word.word);
          if (chars.isEmpty) {
            return Text('$moduleLabel 정보가 없습니다.');
          }
          final widgets = <Widget>[];
          for (int i = 0; i < chars.length; i++) {
            widgets.add(ChineseCharWidget(char: chars[i]));
            if (i < chars.length - 1) {
              widgets.add(const SizedBox(height: AppSpacing.md));
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$moduleLabel 정보',
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...widgets,
            ],
          );
        },
      ),
    );
  }
}
