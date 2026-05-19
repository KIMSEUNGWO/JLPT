import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/daily_stats_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late AppMetaRepository meta;
  late DailyStatsRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    meta = AppMetaRepository(db);
    repo = DailyStatsRepository(db, meta);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await LocalStorage.initInstance();
  });

  tearDown(() => db.close());

  int dateNDaysAgo(int n) =>
      LocalStorage.dateToInt(DateTime.now().subtract(Duration(days: n)));

  group('getThisWeek', () {
    test('빈 DB → 7일 모두 0 row 로 채워서 반환', () async {
      final week = await repo.getThisWeek();
      expect(week.length, 7);
      expect(week.every((r) => r.studySeconds == 0), true);
      expect(week.every((r) => r.wordsLearned == 0), true);
    });

    test('일부 날짜에 row 가 있으면 그 값 그대로, 빈 날은 0', () async {
      await db.dailyStatDao
          .increment(date: dateNDaysAgo(0), seconds: 100, words: 5);
      await db.dailyStatDao.increment(date: dateNDaysAgo(2), words: 3);
      final week = await repo.getThisWeek();
      expect(week.length, 7);
      expect(week.last.studySeconds, 100);
      expect(week.last.wordsLearned, 5);
      expect(week[week.length - 1 - 2].wordsLearned, 3);
    });
  });

  group('getStreak', () {
    test('빈 DB → 0', () async {
      expect(await repo.getStreak(), 0);
    });

    test('오늘 학습 → 1', () async {
      await repo.recordWord();
      expect(await repo.getStreak(), 1);
    });

    test('어제부터 5일 연속 + 오늘 안 함 → 5', () async {
      for (var i = 1; i <= 5; i++) {
        await db.dailyStatDao.increment(date: dateNDaysAgo(i), words: 1);
      }
      expect(await repo.getStreak(), 5);
    });

    test('중간 빈 날 → 그 이전 끊김', () async {
      // 오늘, 어제 학습 / 그저께 안 함 / 3일전 학습
      await db.dailyStatDao.increment(date: dateNDaysAgo(0), words: 1);
      await db.dailyStatDao.increment(date: dateNDaysAgo(1), words: 1);
      await db.dailyStatDao.increment(date: dateNDaysAgo(3), words: 1);
      expect(await repo.getStreak(), 2);
    });

    test('seconds 만 누적되어도 active 로 카운트', () async {
      await db.dailyStatDao.increment(date: dateNDaysAgo(0), seconds: 30);
      expect(await repo.getStreak(), 1);
    });
  });

  group('best streak', () {
    test('recordWord 후 best 가 current 와 같아짐', () async {
      await repo.recordWord();
      expect(await repo.getBestStreak(), 1);
    });

    test('best 가 current 보다 크면 갱신 안 됨', () async {
      await meta.setBestStreak(10);
      await repo.recordWord();
      expect(await repo.getBestStreak(), 10);
    });
  });

  group('bootstrapFromLocalStorage', () {
    test('첫 호출 → SharedPreferences 의 오늘치를 옮기고 marker 설정', () async {
      // SharedPreferences 의 오늘치 셋업
      final today = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          StorageKey.TODAY.name, LocalStorage.dateToInt(today));
      await prefs.setInt(StorageKey.TODAY_HOURS.name, 600);
      await prefs.setInt(StorageKey.TODAY_WORDS.name, 12);
      // LocalStorage 가 새 데이터로 다시 read 하도록 재초기화
      await LocalStorage.initInstance();

      await repo.bootstrapFromLocalStorage();
      final row =
          await db.dailyStatDao.getByDate(LocalStorage.dateToInt(today));
      expect(row, isNotNull);
      expect(row!.studySeconds, 600);
      expect(row.wordsLearned, 12);
      expect(await meta.isStatsBackfilledV3(), true);
    });

    test('이미 백필된 상태에서 다시 호출 → 누적 안 됨 (idempotent)', () async {
      final today = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          StorageKey.TODAY.name, LocalStorage.dateToInt(today));
      await prefs.setInt(StorageKey.TODAY_HOURS.name, 600);
      await LocalStorage.initInstance();

      await repo.bootstrapFromLocalStorage();
      await repo.bootstrapFromLocalStorage();

      final row =
          await db.dailyStatDao.getByDate(LocalStorage.dateToInt(today));
      expect(row!.studySeconds, 600); // 1200 이 아님
    });

    test('SharedPreferences 가 비어있으면 row 생성 안 함, marker 만 set', () async {
      await repo.bootstrapFromLocalStorage();
      final row = await db.dailyStatDao
          .getByDate(LocalStorage.dateToInt(DateTime.now()));
      expect(row, isNull);
      expect(await meta.isStatsBackfilledV3(), true);
    });
  });
}
