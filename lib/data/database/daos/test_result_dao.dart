import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/database/tables/test_questions_table.dart';
import 'package:jlpt_app/data/database/tables/test_results_table.dart';

part 'test_result_dao.g.dart';

@DriftAccessor(tables: [TestResults, TestQuestions])
class TestResultDao extends DatabaseAccessor<AppDatabase>
    with _$TestResultDaoMixin {
  TestResultDao(super.db);

  Future<List<TestResultData>> getAllResults(String course) =>
      (select(testResults)
            ..where((t) => t.course.equals(course))
            ..orderBy([(t) => OrderingTerm.desc(t.takenAt)]))
          .get();

  Future<List<TestQuestionData>> getQuestionsFor(int resultId) => (select(
    testQuestions,
  )..where((t) => t.testResultId.equals(resultId))).get();

  /// 지정한 결과들의 질문을 한 번에 조회 (N+1 방지)
  Future<List<TestQuestionData>> getQuestionsForResults(List<int> resultIds) {
    if (resultIds.isEmpty) return Future.value(const []);
    return (select(
      testQuestions,
    )..where((t) => t.testResultId.isIn(resultIds))).get();
  }

  Future<int> insertResult(TestResultsCompanion row) =>
      into(testResults).insert(row);

  Future<void> insertQuestion(TestQuestionsCompanion row) =>
      into(testQuestions).insert(row);
}
