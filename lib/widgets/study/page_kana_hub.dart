import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/app/route_args.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/core/theme/theme_x.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/study_level_kind.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/notifier/recently_view_notifier.dart';
import 'package:jlpt_app/widgets/component/learning_area_tile.dart';

/// 카나(히라가나/가타카나) 허브. 한 스크립트의 '문자'·'단어' 학습을
/// 완전히 분리된 두 항목으로 보여준다. 각 항목은 기존 학습 리스트로 진입.
class KanaHubPage extends ConsumerWidget {
  const KanaHubPage({super.key, required this.script});

  /// 'hiragana' 또는 'katakana'.
  final String script;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsByLevelProvider);
    final course = ref.watch(activeCourseProvider);
    final isHiragana = script == 'hiragana';
    final levels = course.levels
        .where((l) => isHiragana ? l.isHiragana : l.isKatakana)
        .toList();
    final title = isHiragana ? '히라가나 익히기' : '가타카나 익히기';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        backgroundColor: context.colors.surface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: wordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('목록을 불러올 수 없습니다\n$e')),
            data: (wordsByLevel) => ListView.separated(
              itemCount: levels.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) => _KanaModeTile(
                level: levels[index],
                words: wordsByLevel[levels[index]] ?? const [],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KanaModeTile extends ConsumerWidget {
  const _KanaModeTile({required this.level, required this.words});

  final Level level;
  final List<Word> words;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(recentlyViewProvider);
    final isRecent = view.level == level && view.type == PracticeType.WORD;
    final isChar = level.isKanaChar;

    return LearningAreaTile(
      title: isChar ? '문자' : '단어',
      subtitle: isChar ? '오십음도 전체를 한 번에 학습합니다' : '카나로 이루어진 단어를 학습합니다',
      icon: isChar ? Icons.text_fields_rounded : Icons.menu_book_outlined,
      current: words.where((w) => w.isRead).length,
      total: words.length,
      highlighted: isRecent,
      // 문자(오십음도)는 묶음 분할 없이 전체를 바로 카드 학습한다.
      // 단어는 기존처럼 묶음 선택 리스트를 거친다.
      onTap: isChar
          ? () => _studyAllChars(context, ref)
          : () => context.push(AppRoutes.study(level.code)),
    );
  }

  Future<void> _studyAllChars(BuildContext context, WidgetRef ref) async {
    ref
        .read(recentlyViewProvider.notifier)
        .view(level: level, type: PracticeType.WORD, index: 0);
    await context.push(
      AppRoutes.studyGroupFull(level.code),
      extra: StudyGroupArgs(
        level: level,
        startIndex: 0,
        endIndex: words.length,
      ),
    );
    // 회독 완료 처리·모달은 단일 세트라 StudyPage 가 직접 담당한다.
    // 여기선 복귀 시 진행도만 갱신.
    ref.invalidate(wordsByLevelProvider);
  }
}
