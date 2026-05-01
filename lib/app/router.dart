import 'package:go_router/go_router.dart';
import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/domain/box/question_entity_box.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/initdata/init.dart';
import 'package:jlpt_app/widgets/page_main.dart';
import 'package:jlpt_app/widgets/study/card/page_study.dart';
import 'package:jlpt_app/widgets/study/page_study_list.dart';
import 'package:jlpt_app/widgets/study/test/result/test_result_detail_page.dart';
import 'package:jlpt_app/widgets/study/test/result/test_result_page.dart';
import 'package:jlpt_app/widgets/study/test/test_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.root,
  routes: [
    GoRoute(
      path: AppRoutes.root,
      builder: (context, state) => const InitWidget(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: AppRoutes.studyLevel,
      builder: (context, state) {
        final level = Level.valueOf(state.pathParameters['level']!);
        final words = state.extra as List<Word>? ?? [];
        return StudyListPage(level: level, words: words);
      },
      routes: [
        GoRoute(
          path: AppRoutes.studyGroup,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return StudyPage(
              level: extra['level'] as Level,
              words: extra['words'] as List<Word>,
              startIndex: extra['startIndex'] as int,
              endIndex: extra['endIndex'] as int,
              getSeconds: extra['getSeconds'] as Function(int),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.test,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return TestPage(
          type: extra['type'] as PracticeType,
          level: extra['level'] as Level?,
          mount: extra['mount'] as int,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.testResults,
      builder: (context, state) =>
          TestResultPage(result: state.extra as QuestionEntityBox?),
      routes: [
        GoRoute(
          path: AppRoutes.testResultDetail,
          builder: (context, state) =>
              TestResultDetailPage(question: state.extra as QuestionEntityBox),
        ),
      ],
    ),
  ],
);
