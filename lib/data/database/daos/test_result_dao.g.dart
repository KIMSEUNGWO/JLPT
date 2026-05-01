// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_result_dao.dart';

// ignore_for_file: type=lint
mixin _$TestResultDaoMixin on DatabaseAccessor<AppDatabase> {
  $TestResultsTable get testResults => attachedDatabase.testResults;
  $TestQuestionsTable get testQuestions => attachedDatabase.testQuestions;
  TestResultDaoManager get managers => TestResultDaoManager(this);
}

class TestResultDaoManager {
  final _$TestResultDaoMixin _db;
  TestResultDaoManager(this._db);
  $$TestResultsTableTableManager get testResults =>
      $$TestResultsTableTableManager(_db.attachedDatabase, _db.testResults);
  $$TestQuestionsTableTableManager get testQuestions =>
      $$TestQuestionsTableTableManager(_db.attachedDatabase, _db.testQuestions);
}
