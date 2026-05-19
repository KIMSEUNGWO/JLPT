import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  group('DailyStatDao.increment', () {
    test('비어있는 row 에 INSERT', () async {
      await db.dailyStatDao
          .increment(date: 20260519, seconds: 120, words: 3);
      final row = await db.dailyStatDao.getByDate(20260519);
      expect(row, isNotNull);
      expect(row!.studySeconds, 120);
      expect(row.wordsLearned, 3);
      expect(row.grammarsLearned, 0);
    });

    test('두 번 호출 시 누적 (UPSERT 가산)', () async {
      await db.dailyStatDao.increment(date: 20260519, seconds: 60);
      await db.dailyStatDao.increment(date: 20260519, seconds: 90, words: 2);
      final row = await db.dailyStatDao.getByDate(20260519);
      expect(row!.studySeconds, 150);
      expect(row.wordsLearned, 2);
    });

    test('다른 date 는 독립적으로 누적', () async {
      await db.dailyStatDao.increment(date: 20260518, words: 5);
      await db.dailyStatDao.increment(date: 20260519, words: 7);
      expect((await db.dailyStatDao.getByDate(20260518))!.wordsLearned, 5);
      expect((await db.dailyStatDao.getByDate(20260519))!.wordsLearned, 7);
    });

    test('모든 컬럼 동시 increment 후 누적 정합', () async {
      await db.dailyStatDao.increment(
        date: 20260519,
        seconds: 30,
        words: 1,
        grammars: 2,
        testsTaken: 1,
        correct: 4,
        total: 5,
      );
      await db.dailyStatDao.increment(
        date: 20260519,
        seconds: 30,
        words: 1,
        grammars: 2,
        testsTaken: 1,
        correct: 3,
        total: 5,
      );
      final row = await db.dailyStatDao.getByDate(20260519);
      expect(row!.studySeconds, 60);
      expect(row.wordsLearned, 2);
      expect(row.grammarsLearned, 4);
      expect(row.testsTaken, 2);
      expect(row.correctAnswers, 7);
      expect(row.totalAnswers, 10);
    });

    test('getRange 는 from ≤ date ≤ to 만 반환', () async {
      await db.dailyStatDao.increment(date: 20260517, words: 1);
      await db.dailyStatDao.increment(date: 20260518, words: 1);
      await db.dailyStatDao.increment(date: 20260519, words: 1);
      await db.dailyStatDao.increment(date: 20260520, words: 1);

      final rows = await db.dailyStatDao.getRange(20260518, 20260519);
      expect(rows.length, 2);
      expect(rows.map((r) => r.date).toList(), [20260518, 20260519]);
    });
  });
}
