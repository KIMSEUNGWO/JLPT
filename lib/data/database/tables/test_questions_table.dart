import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/tables/test_results_table.dart';

@DataClassName('TestQuestionData')
class TestQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get testResultId => integer().references(TestResults, #id)();
  IntColumn get questionWordId => integer()();
  IntColumn get myAnswerWordId => integer().nullable()();
  BoolColumn get isCorrect => boolean()();
  BoolColumn get reverse => boolean()();
  TextColumn get examplesJson => text()(); // JSON array of word IDs: [1, 5, 23, 42]
}
