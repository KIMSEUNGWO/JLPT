// ignore_for_file: experimental_member_use

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:jlpt_app/data/database/daos/app_meta_dao.dart';
import 'package:jlpt_app/data/database/daos/chinese_char_dao.dart';
import 'package:jlpt_app/data/database/daos/daily_stat_dao.dart';
import 'package:jlpt_app/data/database/daos/example_sentence_dao.dart';
import 'package:jlpt_app/data/database/daos/test_result_dao.dart';
import 'package:jlpt_app/data/database/daos/word_dao.dart';
import 'package:jlpt_app/data/database/tables/app_meta_table.dart';
import 'package:jlpt_app/data/database/tables/chinese_chars_table.dart';
import 'package:jlpt_app/data/database/tables/daily_stats_table.dart';
import 'package:jlpt_app/data/database/tables/example_sentences_table.dart';
import 'package:jlpt_app/data/database/tables/test_questions_table.dart';
import 'package:jlpt_app/data/database/tables/test_results_table.dart';
import 'package:jlpt_app/data/database/tables/word_example_refs_table.dart';
import 'package:jlpt_app/data/database/tables/words_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Words,
    ChineseChars,
    TestResults,
    TestQuestions,
    AppMeta,
    DailyStats,
    ExampleSentences,
    WordExampleRefs,
  ],
  daos: [
    WordDao,
    ChineseCharDao,
    TestResultDao,
    AppMetaDao,
    DailyStatDao,
    ExampleSentenceDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

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
      if (from < 4) {
        // v4: ExampleSentences + WordExampleRefs 신설.
        // 빈 테이블로 시작하고, 다음 부팅에서 ExampleSentenceSyncer 가
        // 번들 또는 캐시 데이터로 채운다 (메타 examples_version 이 null 이므로
        // 강제 재동기화 트리거).
        await m.createTable(exampleSentences);
        await m.createTable(wordExampleRefs);
      }
      if (from < 5) {
        // v5: 다국어 "코스(Course)" 차원 도입.
        // 콘텐츠/진행/테스트 테이블에 `course` 컬럼을 추가하고 기존 데이터는
        // 모두 JLPT 일본어('jlpt_ja') 로 태깅한다. 컬럼 기본값이 'jlpt_ja' 라
        // 기존 row 는 자동 백필된다.
        //
        // 주의: from<4 분기가 example_sentences/word_example_refs 를 "현재"
        // 스키마(이미 course 포함)로 새로 만들 수 있으므로, 이미 course 가 있는
        // 테이블에는 다시 추가하지 않도록 방어적으로 처리한다.
        await _addCourseColumnIfMissing(m, words, words.course);
        await _addCourseColumnIfMissing(m, chineseChars, chineseChars.course);
        await _addCourseColumnIfMissing(
          m,
          exampleSentences,
          exampleSentences.course,
        );
        await _addCourseColumnIfMissing(
          m,
          wordExampleRefs,
          wordExampleRefs.course,
        );
        await _addCourseColumnIfMissing(m, testResults, testResults.course);

        // 엔티티 버전 메타 키를 코스 네임스페이스로 이전한다.
        // (`words_version` → `words_version:jlpt_ja` 등)
        await _migrateMetaKeysToCourse('jlpt_ja');
      }
      if (from < 6) {
        // v6: course 차원을 실제 키 경계로 승격한다.
        // 기존 v5 row 는 이미 course='jlpt_ja' 로 태깅되어 있으므로,
        // 테이블을 재생성해 복합 PK/FK 정의만 현재 스키마로 맞춘다.
        await _alterTableIfExists(m, words);
        await _alterTableIfExists(m, chineseChars);
        await _alterTableIfExists(m, exampleSentences);
        await _alterTableIfExists(m, wordExampleRefs);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// [table] 이 존재하고 [column] 이 아직 없을 때만 `course` 컬럼을 추가한다.
  /// (이미 현재 스키마로 생성돼 course 를 가진 테이블 / 존재하지 않는 테이블은 skip)
  Future<void> _addCourseColumnIfMissing(
    Migrator m,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    final tableExists = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type='table' AND name = ?1",
      variables: [Variable<String>(table.actualTableName)],
    ).get();
    if (tableExists.isEmpty) return;

    final info = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    final hasColumn = info.any(
      (row) => row.read<String>('name') == column.name,
    );
    if (hasColumn) return;

    await m.addColumn(table, column);
  }

  /// 코스 무관(legacy) 엔티티 버전/시각 메타 키에 `:<courseId>` suffix 를 붙여
  /// 코스 네임스페이스로 이전한다. [AppMetaRepository] 의 키 규칙과 일치해야 한다.
  Future<void> _migrateMetaKeysToCourse(String courseId) async {
    const legacyKeys = [
      'words_version',
      'chars_version',
      'examples_version',
      'words_synced_at',
      'chars_synced_at',
      'examples_synced_at',
    ];
    final inList = legacyKeys.map((k) => "'$k'").join(', ');
    await customStatement(
      'UPDATE app_meta SET "key" = "key" || \':$courseId\' '
      'WHERE "key" IN ($inList)',
    );
  }

  Future<void> _alterTableIfExists(Migrator m, TableInfo table) async {
    final tableExists = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type='table' AND name = ?1",
      variables: [Variable<String>(table.actualTableName)],
    ).get();
    if (tableExists.isEmpty) return;

    await m.alterTable(TableMigration(table));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'jlpt_go.db'));
    return NativeDatabase.createInBackground(file);
  });
}
