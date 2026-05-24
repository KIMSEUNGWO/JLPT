import 'package:go_router/go_router.dart';
import 'package:jlpt_app/app/app_routes.dart';
import 'package:jlpt_app/app/route_args.dart';
import 'package:jlpt_app/domain/course/course_registry.dart';
import 'package:jlpt_app/widgets/page_main.dart';
import 'package:jlpt_app/widgets/page_settings.dart';
import 'package:jlpt_app/widgets/startup_gate.dart';
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
      builder: (context, state) => const StartupGate(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: AppRoutes.studyLevel,
      builder: (context, state) {
        // UI 는 단일 코스 — 기본 코스로 레벨 코드를 해석한다.
        // 코스 선택 UI 추가 시 활성 코스로 교체.
        final level =
            CourseRegistry.defaultCourse.levelOf(state.pathParameters['level']!);
        return StudyListPage(level: level);
      },
      routes: [
        GoRoute(
          path: AppRoutes.studyGroup,
          builder: (context, state) {
            final args = state.extra as StudyGroupArgs;
            return StudyPage(args: args);
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.test,
      builder: (context, state) {
        final args = state.extra as TestArgs;
        return TestPage(args: args);
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.testResults,
      builder: (context, state) {
        final extra = state.extra;
        final args = extra is TestResultsArgs
            ? extra
            : const TestResultsArgs();
        return TestResultPage(result: args.result);
      },
      routes: [
        GoRoute(
          path: AppRoutes.testResultDetail,
          builder: (context, state) {
            final args = state.extra as TestResultDetailArgs;
            return TestResultDetailPage(question: args.question);
          },
        ),
      ],
    ),
  ],
);
