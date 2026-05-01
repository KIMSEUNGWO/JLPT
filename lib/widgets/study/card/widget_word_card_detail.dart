import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/widgets/study/card/widget_chinese_char.dart';

class WordCardDetailWidget extends ConsumerWidget {
  final Word word;

  const WordCardDetailWidget({super.key, required this.word});

  List<ChineseChar> _findChars(Map<String, ChineseChar> map, String text) =>
      text.characters
          .map((c) => map[c])
          .whereType<ChineseChar>()
          .toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheAsync = ref.watch(chineseCharCacheProvider);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 21),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: cacheAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const Text('한자 정보를 불러올 수 없습니다.'),
        data: (charMap) {
          final chars = _findChars(charMap, word.word);
          if (chars.isEmpty) return const Text('한자 정보가 없습니다.');

          final widgets = <Widget>[];
          for (int i = 0; i < chars.length; i++) {
            widgets.add(ChineseCharWidget(char: chars[i]));
            if (i < chars.length - 1) {
              widgets.add(const SizedBox(height: 10));
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('한자 정보',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize:
                          Theme.of(context).textTheme.bodyMedium!.fontSize)),
              const SizedBox(height: 12),
              ...widgets,
            ],
          );
        },
      ),
    );
  }
}
