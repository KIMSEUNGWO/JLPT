import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/database/tables/test_questions_table.dart';
import 'package:jlpt_app/data/database/tables/test_results_table.dart';

part 'test_result_dao.g.dart';

@DriftAccessor(tables: [TestResults, TestQuestions])
class TestResultDao extends DatabaseAccessor<AppDatabase>
    with _$TestResultDaoMixin {
  TestResultDao(super.db);

  Future<List<TestResultData>> getAllResults() =>
      (select(testResults)..orderBy([(t) => OrderingTerm.desc(t.takenAt)]))
          .get();

  Future<List<TestQuestionData>> getQuestionsFor(int resultId) =>
      (select(testQuestions)..where((t) => t.testResultId.equals(resultId)))
          .get();

  /// 모든 결과의 질문을 한 번에 조회 (N+1 방지)
  Future<List<TestQuestionData>> getAllQuestions() =>
      select(testQuestions).get();

  Future<int> insertResult(TestResultsCompanion row) =>
      into(testResults).insert(row);

  Future<void> insertQuestion(TestQuestionsCompanion row) =>
      into(testQuestions).insert(row);
}
