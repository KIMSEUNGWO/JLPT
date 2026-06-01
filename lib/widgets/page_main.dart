import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/app/route_args.dart';
import 'package:jlpt_app/core/theme/app_spacing.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/study_level_kind.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/notifier/recently_view_notifier.dart';
import 'package:jlpt_app/widgets/component/ads_banner.dart';
import 'package:jlpt_app/widgets/component/continue_study_card.dart';
import 'package:jlpt_app/widgets/component/custom_container.dart';
import 'package:jlpt_app/widgets/component/learning_area_tile.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsByLevelProvider);
    final course = ref.watch(activeCourseProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () => context.push(AppRoutes.testResults),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Center(child: Text('테스트 기록')),
            ),
          ),
          IconButton(
            tooltip: '환경설정',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final recentView = ref.watch(recentlyViewProvider);
                    final hasRecent =
                        recentView.level != null &&
                        recentView.type == PracticeType.WORD &&
                        recentView.index != null;
                    if (!hasRecent) return const SizedBox.shrink();

                    return Column(
                      children: [
                        CustomContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: wordsAsync.when(
                            loading: () => const SizedBox(
                              height: 120,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, __) => const SizedBox(
                              height: 80,
                              child: Center(child: Text('학습 정보를 불러올 수 없습니다')),
                            ),
                            data: (wordsByLevel) => ContinueStudyCard(
                              wordsByLevel: wordsByLevel,
                              recentView: recentView,
                              onContinue: (target) async {
                                ref
                                    .read(recentlyViewProvider.notifier)
                                    .view(
                                      level: target.level,
                                      type: PracticeType.WORD,
                                      index: target.groupIndex,
                                    );
                                await context.push(
                                  AppRoutes.studyGroupFull(target.level.code),
                                  extra: StudyGroupArgs(
                                    level: target.level,
                                    startIndex: target.startIndex,
                                    endIndex: target.endIndex,
                                  ),
                                );
                                ref.invalidate(wordsByLevelProvider);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                      ],
                    );
                  },
                ),
                wordsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxxl,
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 32),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '단어 목록을 불러올 수 없습니다\n$e',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton.icon(
                          onPressed: () => ref.invalidate(wordsByLevelProvider),
                          icon: const Icon(Icons.refresh),
                          label: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                  data: (_) => _LearningMenu(
                    levels: course.levels,
                    courseName: course.displayName,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const SimpleBannerAd(height: 100),
    );
  }
}

/// 메인 학습 메뉴. 코스가 정의한 레벨을 스크립트(히라가나/가타카나)·JLPT 로 묶어
/// 타일을 만든다. 카나 타일은 허브 페이지(`/kana/:script`)로 진입해 그 안에서
/// 문자·단어가 분리된다. 카나가 없는 코스에서는 카나 타일이 자연히 생략된다.
class _LearningMenu extends StatelessWidget {
  const _LearningMenu({required this.levels, required this.courseName});

  final List<Level> levels;
  final String courseName;

  @override
  Widget build(BuildContext context) {
    final hiragana = levels.where((l) => l.isHiragana).toList();
    final katakana = levels.where((l) => l.isKatakana).toList();
    final jlpt = levels.where((l) => l.isJlpt).toList();

    final tiles = <Widget>[
      if (hiragana.isNotEmpty)
        LearningAreaTile(
          title: '히라가나 익히기',
          subtitle: '문자(오십음도)와 단어를 학습합니다',
          icon: Icons.text_fields_rounded,
          showProgress: false,
          onTap: () => context.push(AppRoutes.kana('hiragana')),
        ),
      if (katakana.isNotEmpty)
        LearningAreaTile(
          title: '가타카나 익히기',
          subtitle: '문자(오십음도)와 단어를 학습합니다',
          icon: Icons.translate_rounded,
          showProgress: false,
          onTap: () => context.push(AppRoutes.kana('katakana')),
        ),
      if (jlpt.isNotEmpty)
        LearningAreaTile(
          title: '$courseName 학습',
          subtitle:
              '${jlpt.first.label}부터 ${jlpt.last.label}까지 '
              '단어와 테스트를 학습합니다',
          icon: Icons.school_outlined,
          showProgress: false,
          onTap: () => context.push(AppRoutes.jlpt),
        ),
    ];

    return Column(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          tiles[i],
        ],
      ],
    );
  }
}
