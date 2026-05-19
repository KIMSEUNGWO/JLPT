import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';

/// 일별 학습 통계 read/write 의 단일 진입점.
///
/// - write 메서드는 모두 `DailyStatDao.increment` UPSERT 로 원자적.
/// - read 메서드는 항상 `DateTime.subtract` 로 날짜를 계산 후 `dateToInt` —
///   `YYYYMMDD` int 산술 금지 (월말/연말 깨짐).
class DailyStatsRepository {
  static const _streakWindow = 30;

  final AppDatabase _db;
  final AppMetaRepository _meta;

  DailyStatsRepository(this._db, this._meta);

  Future<void> recordSeconds(int seconds) async {
    if (seconds <= 0) return;
    final today = _today();
    final wasActive = await _isActive(today);
    await _db.dailyStatDao.increment(date: today, seconds: seconds);
    if (!wasActive) await _refreshBestStreak();
  }

  Future<void> recordWord() async {
    final today = _today();
    final wasActive = await _isActive(today);
    await _db.dailyStatDao.increment(date: today, words: 1);
    if (!wasActive) await _refreshBestStreak();
  }

  /// 해당 날짜가 이미 active (= streak 에 포함) 인지. true 이면 record 후에도
  /// streak 길이가 변하지 않으므로 best 재계산을 skip 할 수 있다.
  Future<bool> _isActive(int date) async {
    final row = await _db.dailyStatDao.getByDate(date);
    return row != null && (row.studySeconds > 0 || row.wordsLearned > 0);
  }

  Future<List<DailyStatData>> getThisWeek() async {
    final dates = _lastNDates(7);
    final rows = await _db.dailyStatDao.getRange(dates.first, dates.last);
    final byDate = {for (final r in rows) r.date: r};
    return dates.map((d) => byDate[d] ?? _empty(d)).toList(growable: false);
  }

  /// 오늘 또는 어제부터 거꾸로 연속 학습한 일 수.
  ///
  /// 규칙:
  /// - 오늘 아직 학습 안 했어도 스트릭은 끊기지 않는다 (어제까지 카운트).
  /// - 중간 빈 날이 나오면 거기서 멈춤.
  /// - 윈도우는 최근 30일 (그 이상은 cap).
  Future<int> getStreak() async {
    final dates = _lastNDates(_streakWindow);
    final rows = await _db.dailyStatDao.getRange(dates.first, dates.last);
    final byDate = {for (final r in rows) r.date: r};

    var streak = 0;
    for (var i = dates.length - 1; i >= 0; i--) {
      final r = byDate[dates[i]];
      final active =
          r != null && (r.studySeconds > 0 || r.wordsLearned > 0);
      if (!active) {
        if (i == dates.length - 1) continue; // 오늘 안 한 건 끊김으로 안 침
        break;
      }
      streak++;
    }
    return streak;
  }

  Future<int> getBestStreak() async => (await _meta.getBestStreak()) ?? 0;

  Future<void> _refreshBestStreak() async {
    final current = await getStreak();
    final best = await getBestStreak();
    if (current > best) await _meta.setBestStreak(current);
  }

  /// 첫 v3 부팅에서 SharedPreferences 의 오늘치 hours/wordCnt 를 옮긴다.
  /// `AppMeta` marker 로 idempotent — 재부팅마다 중복 누적되지 않는다.
  Future<void> bootstrapFromLocalStorage() async {
    if (await _meta.isStatsBackfilledV3()) return;
    final td = LocalStorage.instance.getTodayData();
    if (td.hours > 0 || td.wordCnt > 0) {
      await _db.dailyStatDao.increment(
        date: td.date,
        seconds: td.hours,
        words: td.wordCnt,
      );
    }
    await _meta.markStatsBackfilledV3();
  }

  int _today() => LocalStorage.dateToInt(DateTime.now());

  /// 오늘 포함 최근 [n] 일의 int 날짜 — 오름차순.
  List<int> _lastNDates(int n) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day - (n - 1));
    return List<int>.generate(
      n,
      (i) => LocalStorage.dateToInt(start.add(Duration(days: i))),
    );
  }

  DailyStatData _empty(int date) => DailyStatData(
        date: date,
        studySeconds: 0,
        wordsLearned: 0,
        grammarsLearned: 0,
        testsTaken: 0,
        correctAnswers: 0,
        totalAnswers: 0,
      );
}
