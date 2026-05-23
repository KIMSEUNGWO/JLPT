import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/test_result_repository.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:pub_semver/pub_semver.dart';

Word _makeWord(int id) => Word(
      id: id,
      level: Level.N5,
      act: Act.N,
      word: 'word$id',
      hiragana: 'hira$id',
      korean: '단어$id',
      isRead: false,
      wrongCnt: 0,
      exampleIds: [100000 + id],
    );

void main() {
  late AppDatabase db;
  late TestResultRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final meta = AppMetaRepository(db);
    final wordRepo = WordRepository(db, meta);
    repo = TestResultRepository(db, wordRepo);

    // Foreign key 참조용으로 단어 row 를 미리 넣어둔다.
    await wordRepo.syncAll(
      [
        for (var i = 1; i <= 4; i++) _makeWord(i),
      ],
      version: Version.parse('1.0.0'),
    );
  });

  tearDown(() => db.close());

  test('save() 가 같은 transaction 에서 daily_stats 를 누적한다', () async {
    final q1 = Question.create(question: _makeWord(1), examples: [
      _makeWord(2),
      _makeWord(3),
      _makeWord(4),
    ])
      ..myAnswer = _makeWord(1); // 정답
    final q2 = Question.create(question: _makeWord(2), examples: [
      _makeWord(1),
      _makeWord(3),
      _makeWord(4),
    ])
      ..myAnswer = _makeWord(3); // 오답

    await repo.save(
      level: Level.N5,
      type: PracticeType.WORD,
      questions: [q1, q2],
      reverses: [false, false],
      time: 30,
    );

    final today = LocalStorage.dateToInt(DateTime.now());
    final row = await db.dailyStatDao.getByDate(today);
    expect(row, isNotNull);
    expect(row!.testsTaken, 1);
    expect(row.correctAnswers, 1);
    expect(row.totalAnswers, 2);
  });

  test('두 번 save → testsTaken 누적', () async {
    Future<void> doSave() async {
      final q = Question.create(question: _makeWord(1), examples: [
        _makeWord(2),
        _makeWord(3),
        _makeWord(4),
      ])
        ..myAnswer = _makeWord(1);
      await repo.save(
        level: Level.N5,
        type: PracticeType.WORD,
        questions: [q],
        reverses: [false],
        time: 10,
      );
    }

    await doSave();
    await doSave();

    final today = LocalStorage.dateToInt(DateTime.now());
    final row = await db.dailyStatDao.getByDate(today);
    expect(row!.testsTaken, 2);
    expect(row.correctAnswers, 2);
    expect(row.totalAnswers, 2);
  });
}
