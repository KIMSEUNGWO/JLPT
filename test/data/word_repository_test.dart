import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:pub_semver/pub_semver.dart';

AppDatabase _inMemoryDb() => AppDatabase.forTesting(NativeDatabase.memory());

final _v1 = Version.parse('1.0.0');
final _v2 = Version.parse('1.0.1');

Word _makeWord(int id, Level level) => Word(
      id: id,
      level: level,
      act: Act.N,
      word: '単語$id',
      hiragana: 'たんご$id',
      korean: '단어$id',
      isRead: false,
      wrongCnt: 0,
    );

void main() {
  late AppDatabase db;
  late AppMetaRepository meta;
  late WordRepository repo;

  setUp(() {
    db = _inMemoryDb();
    meta = AppMetaRepository(db);
    repo = WordRepository(db, meta);
  });

  tearDown(() => db.close());

  group('WordRepository', () {
    test('syncAll → getByLevel 단어 반환', () async {
      final words = [
        _makeWord(1, Level.N5),
        _makeWord(2, Level.N5),
        _makeWord(3, Level.N4),
      ];
      await repo.syncAll(words, version: _v1);

      final n5 = await repo.getByLevel(Level.N5);
      expect(n5.length, 2);
      expect(n5.map((w) => w.id), containsAll([1, 2]));
    });

    test('markRead → isRead = true', () async {
      await repo.syncAll([_makeWord(10, Level.N3)], version: _v1);
      await repo.markRead(10);

      final words = await repo.getByLevel(Level.N3);
      expect(words.first.isRead, isTrue);
    });

    test('resetReadFor → 모두 isRead = false', () async {
      await repo.syncAll(
        [_makeWord(20, Level.N2), _makeWord(21, Level.N2)],
        version: _v1,
      );
      await repo.markAllRead([20, 21]);
      await repo.resetReadFor(Level.N2);

      final words = await repo.getByLevel(Level.N2);
      expect(words.every((w) => !w.isRead), isTrue);
    });

    test('syncAll upsert: 기존 단어의 isRead 유지', () async {
      await repo.syncAll([_makeWord(30, Level.N1)], version: _v1);
      await repo.markRead(30);

      final updated = const Word(
        id: 30,
        level: Level.N1,
        act: Act.V,
        word: '更新',
        hiragana: 'こうしん',
        korean: '업데이트',
        isRead: false,
        wrongCnt: 0,
      );
      await repo.syncAll([updated], version: _v2);

      final words = await repo.getByLevel(Level.N1);
      expect(words.first.isRead, isTrue,
          reason: 'upsert는 isRead 값을 유지해야 한다');
      expect(words.first.word, '更新',
          reason: 'word 내용은 업데이트되어야 한다');
    });

    test('syncAll: 메타 테이블에 버전이 commit 된다', () async {
      await repo.syncAll([_makeWord(99, Level.N5)], version: _v2);
      expect(await meta.getWordsVersion(), _v2);
      expect(await meta.getWordsSyncedAt(), isNotNull);
    });

    test('hasWords: 데이터 없으면 false', () async {
      expect(await repo.hasWords(), isFalse);
    });

    test('hasWords: 데이터 있으면 true', () async {
      await repo.syncAll([_makeWord(40, Level.N5)], version: _v1);
      expect(await repo.hasWords(), isTrue);
    });

    test('countWords 는 정확한 row 수 반환', () async {
      await repo.syncAll(
        [
          _makeWord(50, Level.N5),
          _makeWord(51, Level.N4),
          _makeWord(52, Level.N3),
        ],
        version: _v1,
      );
      expect(await repo.countWords(), 3);
    });
  });
}
