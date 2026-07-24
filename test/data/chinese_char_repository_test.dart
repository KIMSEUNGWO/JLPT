import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/chinese_char_repository.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:pub_semver/pub_semver.dart';

AppDatabase _inMemoryDb() => AppDatabase.forTesting(NativeDatabase.memory());

final _v1 = Version.parse('1.0.0');
final _v2 = Version.parse('1.0.1');

ChineseChar _char(String c) => ChineseChar(
  char: c,
  koreanChar: '한자$c',
  soundReading: const ['on'],
  meanReading: const ['kun'],
);

void main() {
  late AppDatabase db;
  late ChineseCharRepository repo;

  setUp(() {
    db = _inMemoryDb();
    repo = ChineseCharRepository(db, AppMetaRepository(db), courseId: 'jlpt_ja');
  });

  tearDown(() => db.close());

  group('ChineseCharRepository', () {
    test('syncAll upsert 후 개수/내용 반영', () async {
      await repo.syncAll([_char('日'), _char('本')], version: _v1);
      expect(await repo.countChars(), 2);
      expect((await repo.getAll()).keys, containsAll(['日', '本']));
    });

    test('원격에서 빠진 문자는 DB 에서도 삭제된다', () async {
      await repo.syncAll([_char('日'), _char('本'), _char('人')], version: _v1);
      expect(await repo.countChars(), 3);

      // 本 이 빠진 새 데이터셋으로 재sync → 本 은 삭제되어야 한다.
      await repo.syncAll([_char('日'), _char('人')], version: _v2);

      expect(await repo.countChars(), 2);
      expect((await repo.getAll()).keys, unorderedEquals(['日', '人']));
    });
  });
}
