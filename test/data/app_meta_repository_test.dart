import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  late AppDatabase db;
  late AppMetaRepository meta;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    meta = AppMetaRepository(db);
  });

  tearDown(() => db.close());

  const courseId = 'jlpt_ja';

  test('빈 DB → 모든 getter 가 null', () async {
    expect(await meta.getWordsVersion(courseId), isNull);
    expect(await meta.getCharsVersion(courseId), isNull);
    expect(await meta.getWordsSyncedAt(courseId), isNull);
    expect(await meta.getLastSyncError(), isNull);
  });

  test('markWordsSynced 후 readback (코스 네임스페이스 키)', () async {
    final v = Version.parse('1.2.3');
    await meta.markWordsSynced(v, courseId);
    expect(await meta.getWordsVersion(courseId), v);
    expect(await meta.getWordsSyncedAt(courseId), isNotNull);
    // 다른 코스 id 로는 보이지 않아야 한다.
    expect(await meta.getWordsVersion('hsk_zh'), isNull);
  });

  test('성공 sync 는 last_sync_error 를 비운다', () async {
    await meta.recordSyncError('previous failure');
    expect(await meta.getLastSyncError(), 'previous failure');
    await meta.markWordsSynced(Version.parse('2.0.0'), courseId);
    expect(await meta.getLastSyncError(), isNull);
  });

  test('손상된 semver 문자열은 null 반환 (throw 하지 않음)', () async {
    // 내부 raw insert 로 손상 데이터 주입 (네임스페이스 키).
    await db.customStatement(
      "INSERT INTO app_meta (key, value) "
      "VALUES ('words_version:$courseId', 'not-semver')",
    );
    expect(await meta.getWordsVersion(courseId), isNull);
  });
}
