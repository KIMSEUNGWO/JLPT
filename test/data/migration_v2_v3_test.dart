import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/data/database/app_database.dart';

void main() {
  // 임시 디렉터리에 실제 파일 DB 를 만들어 schemaVersion 점프를 검증한다.
  // in-memory 로는 onUpgrade 분기가 실행되지 않음 (항상 createAll).
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('jlpt_migration_test_');
    dbFile = File('${tempDir.path}/jlpt_test.db');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('v2 schema → 현재(v5) open 시 daily_stats 생성 + course 태깅 + 메타 키 이전', () async {
    // ────────────────────────────────────────────────────────────────────
    // 1) v2 시뮬레이션: schemaVersion 만 2 로 표시된 빈 DB 생성 후, AppMeta /
    //    Words 두 테이블에 row 를 직접 insert.
    //
    // Drift 의 정식 v2 -> v3 migration 은 onUpgrade(2, 3) 분기로 호출되는데,
    // 이는 "open 한 DB 의 schemaVersion 이 현재 코드와 다를 때" 실행된다.
    // 따라서 먼저 v2 상태로 user_version=2 인 DB 를 만들고, 같은 파일을 v3
    // AppDatabase 로 열어 onUpgrade 가 호출되는지 검증한다.
    // ────────────────────────────────────────────────────────────────────
    {
      final v2Db = NativeDatabase(dbFile);
      // 최소한의 v2 schema 만 직접 생성 — onUpgrade 분기가 daily_stats 생성을
      // 책임지므로 여기서는 그 외 테이블만 있으면 된다.
      await v2Db.ensureOpen(_FakeExecutorUser());
      await v2Db.runCustom(
        'CREATE TABLE IF NOT EXISTS app_meta '
        '(key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)',
        const [],
      );
      await v2Db.runCustom(
        'CREATE TABLE IF NOT EXISTS words '
        '(id INTEGER NOT NULL PRIMARY KEY, level TEXT NOT NULL, '
        'act TEXT NOT NULL, word TEXT NOT NULL, hiragana TEXT NOT NULL, '
        'korean TEXT NOT NULL, is_read INTEGER NOT NULL, '
        'wrong_cnt INTEGER NOT NULL)',
        const [],
      );
      await v2Db.runCustom(
        "INSERT INTO app_meta(key, value) VALUES ('words_version', '1.2.3')",
        const [],
      );
      await v2Db.runCustom(
        "INSERT INTO words(id, level, act, word, hiragana, korean, is_read, wrong_cnt) "
        "VALUES (1, 'N5', 'N', '本', 'ほん', '책', 0, 0)",
        const [],
      );
      await v2Db.runCustom('PRAGMA user_version = 2', const []);
      await v2Db.close();
    }

    // ────────────────────────────────────────────────────────────────────
    // 2) v3 AppDatabase 로 같은 파일을 open → onUpgrade(2, 3) 실행
    // ────────────────────────────────────────────────────────────────────
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));

    // daily_stats 테이블이 새로 생성되었는지
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type='table' AND name='daily_stats'",
        )
        .get();
    expect(tables.length, 1, reason: 'daily_stats 테이블이 onUpgrade 로 생성돼야 함');

    // 기존 데이터 보존 확인
    final wordsRows =
        await db.customSelect('SELECT COUNT(*) AS c FROM words').get();
    expect(wordsRows.first.read<int>('c'), 1);

    // v5: 기존 words row 가 'jlpt_ja' 로 태깅됐는지
    final courseRows = await db
        .customSelect("SELECT course FROM words WHERE id = 1")
        .get();
    expect(courseRows.first.read<String>('course'), 'jlpt_ja',
        reason: '기존 단어는 jlpt_ja 코스로 태깅돼야 한다');

    // v5: 메타 키가 코스 네임스페이스로 이전됐는지 (옛 키는 사라짐)
    final newMeta = await db
        .customSelect(
          "SELECT value FROM app_meta WHERE key='words_version:jlpt_ja'",
          variables: const <drift.Variable<Object>>[],
        )
        .get();
    expect(newMeta.first.read<String>('value'), '1.2.3');

    final oldMeta = await db
        .customSelect(
          "SELECT value FROM app_meta WHERE key='words_version'",
          variables: const <drift.Variable<Object>>[],
        )
        .get();
    expect(oldMeta, isEmpty, reason: '옛 메타 키는 이전 후 남아있지 않아야 한다');

    await db.close();
  });
}

/// `NativeDatabase.ensureOpen` 이 요구하는 minimum stub.
class _FakeExecutorUser implements drift.QueryExecutorUser {
  @override
  int get schemaVersion => 2;

  @override
  Future<void> beforeOpen(
    drift.QueryExecutor executor,
    drift.OpeningDetails details,
  ) async {}
}
