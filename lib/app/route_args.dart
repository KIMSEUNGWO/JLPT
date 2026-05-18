import 'package:jlpt_app/domain/box/question_entity_box.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';

/// 라우트 `extra` 페이로드는 모두 immutable typed class 로 받는다.
/// Map 캐스팅과 Function extra 의존을 제거하기 위함.
sealed class RouteArgs {
  const RouteArgs();
}

class StudyGroupArgs extends RouteArgs {
  const StudyGroupArgs({
    required this.level,
    required this.startIndex,
    required this.endIndex,
  });
  final Level level;
  final int startIndex;
  final int endIndex;
}

class TestArgs extends RouteArgs {
  const TestArgs({
    required this.type,
    required this.level,
    required this.mount,
  });
  final PracticeType type;
  final Level? level;
  final int mount;
}

class TestResultsArgs extends RouteArgs {
  const TestResultsArgs({this.result});
  final QuestionEntityBox? result;
}

class TestResultDetailArgs extends RouteArgs {
  const TestResultDetailArgs({required this.question});
  final QuestionEntityBox question;
}
