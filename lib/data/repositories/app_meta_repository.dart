import 'package:jlpt_app/data/database/app_database.dart';
import 'package:pub_semver/pub_semver.dart';

/// AppMeta key-value 테이블에 대한 strongly-typed 접근자.
///
/// 데이터 sync 완료 상태 (버전 + 시각 + 마지막 오류) 를 일관된 키로 다루기 위해
/// 모든 키 문자열은 이 클래스 내부에만 노출된다.
class AppMetaRepository {
  static const _kWordsVersion = 'words_version';
  static const _kCharsVersion = 'chars_version';
  static const _kWordsSyncedAt = 'words_synced_at';
  static const _kCharsSyncedAt = 'chars_synced_at';
  static const _kLastSyncError = 'last_sync_error';

  final AppDatabase _db;
  AppMetaRepository(this._db);

  Future<Version?> getWordsVersion() => _readVersion(_kWordsVersion);
  Future<Version?> getCharsVersion() => _readVersion(_kCharsVersion);

  Future<DateTime?> getWordsSyncedAt() => _readDateTime(_kWordsSyncedAt);
  Future<DateTime?> getCharsSyncedAt() => _readDateTime(_kCharsSyncedAt);

  Future<String?> getLastSyncError() => _db.appMetaDao.get(_kLastSyncError);

  /// 단어 sync 성공 marker. 데이터 sync 와 같은 transaction 안에서 호출되어야 한다.
  Future<void> markWordsSynced(Version v) async {
    await _db.appMetaDao.put(_kWordsVersion, v.toString());
    await _db.appMetaDao.put(_kWordsSyncedAt, DateTime.now().toIso8601String());
    await _db.appMetaDao.remove(_kLastSyncError);
  }

  /// 한자 sync 성공 marker.
  Future<void> markCharsSynced(Version v) async {
    await _db.appMetaDao.put(_kCharsVersion, v.toString());
    await _db.appMetaDao.put(_kCharsSyncedAt, DateTime.now().toIso8601String());
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
