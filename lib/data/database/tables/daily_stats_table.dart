import 'package:drift/drift.dart';

/// 일별 학습 통계 — 하루 한 row.
///
/// [date] 는 `LocalStorage.dateToInt` 가 만드는 `YYYYMMDD` 정수.
/// 누적은 `DailyStatDao.increment` 의 SQLite UPSERT 로 원자적 수행.
@DataClassName('DailyStatData')
class DailyStats extends Table {
  IntColumn get date => integer()();
  IntColumn get studySeconds => integer().withDefault(const Constant(0))();
  IntColumn get wordsLearned => integer().withDefault(const Constant(0))();
  IntColumn get grammarsLearned => integer().withDefault(const Constant(0))();
  IntColumn get testsTaken => integer().withDefault(const Constant(0))();
  IntColumn get correctAnswers => integer().withDefault(const Constant(0))();
  IntColumn get totalAnswers => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}
