import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/course/course_registry.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:pub_semver/pub_semver.dart';

AppDatabase _inMemoryDb() => AppDatabase.forTesting(NativeDatabase.memory());

const _course = jlptJapaneseCourse;
const _courseId = 'jlpt_ja';
Level _lv(String code) => _course.levelOf(code);

final _v1 = Version.parse('1.0.0');
final _v2 = Version.parse('1.0.1');

Word _makeWord(int id, String levelCode) => Word(
      id: id,
      levelCode: levelCode,
      act: Act.N,
      word: '単語$id',
      reading: 'たんご$id',
      meaning: '단어$id',
      isRead: false,
      wrongCnt: 0,
      exampleIds: [100000 + id],
    );

void main() {
  late AppDatabase db;
  late AppMetaRepository meta;
  late WordRepository repo;

  setUp(() {
    db = _inMemoryDb();
    meta = AppMetaRepository(db);
    repo = WordRepository(db, meta, _course);
  });

  tearDown(() => db.close());

  group('WordRepository', () {
    test('syncAll → getByLevel 단어 반환', () async {
      final words = [
        _makeWord(1, 'N5'),
        _makeWord(2, 'N5'),
        _makeWord(3, 'N4'),
      ];
      await repo.syncAll(words, version: _v1);

      final n5 = await repo.getByLevel(_lv('N5'));
      expect(n5.length, 2);
      expect(n5.map((w) => w.id), containsAll([1, 2]));
    });

    test('markRead → isRead = true', () async {
      await repo.syncAll([_makeWord(10, 'N3')], version: _v1);
      await repo.markRead(10);

      final words = await repo.getByLevel(_lv('N3'));
      expect(words.first.isRead, isTrue);
    });

    test('resetReadFor → 모두 isRead = false', () async {
      await repo.syncAll(
        [_makeWord(20, 'N2'), _makeWord(21, 'N2')],
        version: _v1,
      );
      await repo.markAllRead([20, 21]);
      await repo.resetReadFor(_lv('N2'));

      final words = await repo.getByLevel(_lv('N2'));
      expect(words.every((w) => !w.isRead), isTrue);
    });

    test('syncAll upsert: 기존 단어의 isRead 유지', () async {
      await repo.syncAll([_makeWord(30, 'N1')], version: _v1);
      await repo.markRead(30);

      const updated = Word(
        id: 30,
        levelCode: 'N1',
        act: Act.V,
        word: '更新',
        reading: 'こうしん',
        meaning: '업데이트',
        isRead: false,
        wrongCnt: 0,
        exampleIds: [100030],
      );
      await repo.syncAll([updated], version: _v2);

      final words = await repo.getByLevel(_lv('N1'));
      expect(words.first.isRead, isTrue,
          reason: 'upsert는 isRead 값을 유지해야 한다');
      expect(words.first.word, '更新',
          reason: 'word 내용은 업데이트되어야 한다');
    });

    test('syncAll: 메타 테이블에 버전이 commit 된다', () async {
      await repo.syncAll([_makeWord(99, 'N5')], version: _v2);
      expect(await meta.getWordsVersion(_courseId), _v2);
      expect(await meta.getWordsSyncedAt(_courseId), isNotNull);
    });

    test('hasWords: 데이터 없으면 false', () async {
      expect(await repo.hasWords(), isFalse);
    });

    test('hasWords: 데이터 있으면 true', () async {
      await repo.syncAll([_makeWord(40, 'N5')], version: _v1);
      expect(await repo.hasWords(), isTrue);
    });

    test('countWords 는 정확한 row 수 반환', () async {
      await repo.syncAll(
        [
          _makeWord(50, 'N5'),
          _makeWord(51, 'N4'),
          _makeWord(52, 'N3'),
        ],
        version: _v1,
      );
      expect(await repo.countWords(), 3);
    });
  });
}
