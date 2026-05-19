import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:jlpt_app/data/database/daos/app_meta_dao.dart';
import 'package:jlpt_app/data/database/daos/chinese_char_dao.dart';
import 'package:jlpt_app/data/database/daos/daily_stat_dao.dart';
import 'package:jlpt_app/data/database/daos/test_result_dao.dart';
import 'package:jlpt_app/data/database/daos/word_dao.dart';
import 'package:jlpt_app/data/database/tables/app_meta_table.dart';
import 'package:jlpt_app/data/database/tables/chinese_chars_table.dart';
import 'package:jlpt_app/data/database/tables/daily_stats_table.dart';
import 'package:jlpt_app/data/database/tables/test_questions_table.dart';
import 'package:jlpt_app/data/database/tables/test_results_table.dart';
import 'package:jlpt_app/data/database/tables/words_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Words, ChineseChars, TestResults, TestQuestions, AppMeta, DailyStats],
  daos: [WordDao, ChineseCharDao, TestResultDao, AppMetaDao, DailyStatDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: AppMeta 테이블 신설.
            // 기존 DB에 데이터가 있을 수 있으므로, 보수적으로 "버전 미상"으로 둔다.
            // 다음 부팅에서 DataSyncService 가 번들 버전으로 강제 재동기화한다.
            await m.createTable(appMeta);
          }
          if (from < 3) {
            // v3: DailyStats 테이블 신설.
            // 기존 사용자의 오늘치 SharedPreferences 수치는
            // DailyStatsRepository.bootstrapFromLocalStorage 가 1회 백필.
            await m.createTable(dailyStats);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'jlpt_go.db'));
    return NativeDatabase.createInBackground(file);
  });
}
