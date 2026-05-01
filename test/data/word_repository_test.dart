import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';

AppDatabase _inMemoryDb() =>
    AppDatabase.forTesting(NativeDatabase.memory());

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
  late WordRepository repo;

  setUp(() {
    db = _inMemoryDb();
    repo = WordRepository(db);
  });

  tearDown(() => db.close());

  group('WordRepository', () {
    test('syncAll → getByLevel 단어 반환', () async {
      final words = [_makeWord(1, Level.N5), _makeWord(2, Level.N5), _makeWord(3, Level.N4)];
      await repo.syncAll(words);

      final n5 = await repo.getByLevel(Level.N5);
      expect(n5.length, 2);
      expect(n5.map((w) => w.id), containsAll([1, 2]));
    });

    test('markRead → isRead = true', () async {
      await repo.syncAll([_makeWord(10, Level.N3)]);
      await repo.markRead(10);

      final words = await repo.getByLevel(Level.N3);
      expect(words.first.isRead, isTrue);
    });

    test('resetReadFor → 모두 isRead = false', () async {
      await repo.syncAll([_makeWord(20, Level.N2), _makeWord(21, Level.N2)]);
      await repo.markAllRead([20, 21]);
      await repo.resetReadFor(Level.N2);

      final words = await repo.getByLevel(Level.N2);
      expect(words.every((w) => !w.isRead), isTrue);
    });

    test('syncAll upsert: 기존 단어의 isRead 유지', () async {
      await repo.syncAll([_makeWord(30, Level.N1)]);
      await repo.markRead(30);

      final updated = Word(
        id: 30,
        level: Level.N1,
        act: Act.V,
        word: '更新',
        hiragana: 'こうしん',
        korean: '업데이트',
        isRead: false,
        wrongCnt: 0,
      );
      await repo.syncAll([updated]);

      final words = await repo.getByLevel(Level.N1);
      expect(words.first.isRead, isTrue, reason: 'upsert는 isRead 값을 유지해야 한다');
      expect(words.first.word, '更新', reason: 'word 내용은 업데이트되어야 한다');
    });

    test('hasWords: 데이터 없으면 false', () async {
      expect(await repo.hasWords(), isFalse);
    });

    test('hasWords: 데이터 있으면 true', () async {
      await repo.syncAll([_makeWord(40, Level.N5)]);
      expect(await repo.hasWords(), isTrue);
    });
  });
}
