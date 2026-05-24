import 'package:jlpt_app/data/database/app_database.dart';
import 'package:pub_semver/pub_semver.dart';

/// AppMeta key-value 테이블에 대한 strongly-typed 접근자.
///
/// 데이터 sync 완료 상태 (버전 + 시각 + 마지막 오류) 를 일관된 키로 다루기 위해
/// 모든 키 문자열은 이 클래스 내부에만 노출된다.
class AppMetaRepository {
  // 엔티티 버전/시각 키는 코스별로 네임스페이스된다: `<base>:<courseId>`.
  // (예: `words_version:jlpt_ja`) — v5 마이그레이션이 legacy 키를 이전한다.
  static const _kWordsVersion = 'words_version';
  static const _kCharsVersion = 'chars_version';
  static const _kExamplesVersion = 'examples_version';
  static const _kWordsSyncedAt = 'words_synced_at';
  static const _kCharsSyncedAt = 'chars_synced_at';
  static const _kExamplesSyncedAt = 'examples_synced_at';
  // 아래는 코스 횡단 전역 키.
  static const _kLastSyncError = 'last_sync_error';
  static const _kBestStreak = 'best_streak';
  static const _kStatsBackfilledV3 = 'daily_stats_backfilled_v3';

  final AppDatabase _db;
  AppMetaRepository(this._db);

  static String _scoped(String base, String courseId) => '$base:$courseId';

  Future<Version?> getWordsVersion(String courseId) =>
      _readVersion(_scoped(_kWordsVersion, courseId));
  Future<Version?> getCharsVersion(String courseId) =>
      _readVersion(_scoped(_kCharsVersion, courseId));
  Future<Version?> getExamplesVersion(String courseId) =>
      _readVersion(_scoped(_kExamplesVersion, courseId));

  Future<DateTime?> getWordsSyncedAt(String courseId) =>
      _readDateTime(_scoped(_kWordsSyncedAt, courseId));
  Future<DateTime?> getCharsSyncedAt(String courseId) =>
      _readDateTime(_scoped(_kCharsSyncedAt, courseId));
  Future<DateTime?> getExamplesSyncedAt(String courseId) =>
      _readDateTime(_scoped(_kExamplesSyncedAt, courseId));

  Future<String?> getLastSyncError() => _db.appMetaDao.get(_kLastSyncError);

  /// 사용자의 역대 최고 연속 학습일. 없으면 null.
  Future<int?> getBestStreak() async {
    final raw = await _db.appMetaDao.get(_kBestStreak);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  Future<void> setBestStreak(int value) =>
      _db.appMetaDao.put(_kBestStreak, value.toString());

  /// v3 마이그레이션 시 SharedPreferences 의 오늘치를 DailyStats 로 1회만 백필
  /// 하기 위한 idempotent marker.
  Future<bool> isStatsBackfilledV3() async {
    final raw = await _db.appMetaDao.get(_kStatsBackfilledV3);
    return raw != null;
  }

  Future<void> markStatsBackfilledV3() =>
      _db.appMetaDao.put(_kStatsBackfilledV3, '1');

  /// 단어 sync 성공 marker. 데이터 sync 와 같은 transaction 안에서 호출되어야 한다.
  Future<void> markWordsSynced(Version v, String courseId) async {
    await _db.appMetaDao.put(_scoped(_kWordsVersion, courseId), v.toString());
    await _db.appMetaDao.put(
        _scoped(_kWordsSyncedAt, courseId), DateTime.now().toIso8601String());
    await _db.appMetaDao.remove(_kLastSyncError);
  }

  /// 한자 sync 성공 marker.
  Future<void> markCharsSynced(Version v, String courseId) async {
    await _db.appMetaDao.put(_scoped(_kCharsVersion, courseId), v.toString());
    await _db.appMetaDao.put(
        _scoped(_kCharsSyncedAt, courseId), DateTime.now().toIso8601String());
    await _db.appMetaDao.remove(_kLastSyncError);
  }

  /// 예문 sync 성공 marker.
  Future<void> markExamplesSynced(Version v, String courseId) async {
    await _db.appMetaDao
        .put(_scoped(_kExamplesVersion, courseId), v.toString());
    await _db.appMetaDao.put(_scoped(_kExamplesSyncedAt, courseId),
        DateTime.now().toIso8601String());
    await _db.appMetaDao.remove(_kLastSyncError);
  }

  Future<void> recordSyncError(Object error) {
    return _db.appMetaDao.put(_kLastSyncError, error.toString());
  }

  Future<Version?> _readVersion(String key) async {
    final raw = await _db.appMetaDao.get(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Version.parse(raw);
    } on FormatException {
      return null;
    }
  }

  Future<DateTime?> _readDateTime(String key) async {
    final raw = await _db.appMetaDao.get(key);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
