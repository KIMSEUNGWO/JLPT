import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/database/tables/daily_stats_table.dart';

part 'daily_stat_dao.g.dart';

@DriftAccessor(tables: [DailyStats])
class DailyStatDao extends DatabaseAccessor<AppDatabase>
    with _$DailyStatDaoMixin {
  DailyStatDao(super.db);

  Future<DailyStatData?> getByDate(int date) async {
    return (select(dailyStats)..where((t) => t.date.equals(date)))
        .getSingleOrNull();
  }

  Future<List<DailyStatData>> getRange(int from, int to) async {
    return (select(dailyStats)
          ..where((t) => t.date.isBetweenValues(from, to))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// 원자적 UPSERT 누적 — race / 동시성 / 부분 실패 없이 안전.
  ///
  /// 같은 [date] row 가 없으면 INSERT, 있으면 각 컬럼에 인자만큼 += 한다.
  Future<void> increment({
    required int date,
    int seconds = 0,
    int words = 0,
    int grammars = 0,
    int testsTaken = 0,
    int correct = 0,
    int total = 0,
  }) async {
    await customStatement(
      'INSERT INTO daily_stats('
      'date, study_seconds, words_learned, grammars_learned, '
      'tests_taken, correct_answers, total_answers) '
      'VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7) '
      'ON CONFLICT(date) DO UPDATE SET '
      'study_seconds   = study_seconds   + ?2, '
      'words_learned   = words_learned   + ?3, '
      'grammars_learned= grammars_learned+ ?4, '
      'tests_taken     = tests_taken     + ?5, '
      'correct_answers = correct_answers + ?6, '
      'total_answers   = total_answers   + ?7',
      [date, seconds, words, grammars, testsTaken, correct, total],
    );
  }
}
