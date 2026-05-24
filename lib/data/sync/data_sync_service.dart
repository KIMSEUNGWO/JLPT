import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/data/remote/json_data_source.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/daily_stats_repository.dart';
import 'package:jlpt_app/data/sync/json_entity_syncer.dart';
import 'package:jlpt_app/domain/course/course.dart';
import 'package:jlpt_app/initdata/update/version_info.dart';
import 'package:pub_semver/pub_semver.dart';

/// 부팅 / 업데이트 시 활성 [Course] 데이터 동기화를 오케스트레이션.
///
/// 책임:
/// 1. 번들 + 캐시의 버전을 읽어 "현재 사용 가능한 최신 source 버전" 결정
/// 2. DB 메타가 기록한 sync 완료 버전과 비교해 sync 여부 판정
/// 3. 필요하면 [AssetJsonDataSource] 또는 [LocalJsonCacheSource] 로부터 sync
/// 4. 원격 신버전 확인 (네트워크 가능 시) — 실제 다운로드는 [UpdateService] 가 담당
///
/// 엔티티 종류(단어/문자/예문…)는 [syncers] 리스트로 주입된다 — 코스마다
/// 문자 모듈 유무 등이 달라지므로 하드코딩하지 않는다.
class DataSyncService {
  DataSyncService({
    required this.course,
    required this.bundle,
    required this.cache,
    required this.remote,
    required this.syncers,
    required this.metaRepository,
    required this.dailyStatsRepository,
  });

  final Course course;
  final AssetJsonDataSource bundle;
  final LocalJsonCacheSource cache;
  final RemoteJsonDataSource remote;
  final List<JsonEntitySyncer> syncers;
  final AppMetaRepository metaRepository;
  final DailyStatsRepository dailyStatsRepository;

  String get _versionKey => course.data.versionKey;

  /// 앱 부팅 시 호출되는 메인 엔트리.
  ///
  /// 절대 throw 하지 않는다 — 실패해도 앱은 (구버전이라도) 켜져야 한다.
  /// 진단을 위해 메타 테이블의 `last_sync_error` 에 메시지를 남긴다.
  Future<SyncReport> ensureSynced() async {
    SyncReport result;
    try {
      final sourceVersion = await _resolveSourceVersion();
      final source = await _pickSource(sourceVersion);
      try {
        result = await _syncFromPickedSource(source, sourceVersion);
      } catch (e) {
        if (source.delegate != cache) rethrow;

        // A stale/corrupt cache must not make the app unusable when bundled
        // data is available. Fall back to the bundled dataset and let the next
        // successful remote update replace the cache.
        appLogger.w('[sync] cache sync failed, falling back to bundle: $e');
        final bundledVersion = await _readVersion(bundle);
        if (bundledVersion == null) rethrow;
        result = await _syncFromPickedSource(
          _PickedSource(bundle, 'bundle-fallback'),
          bundledVersion,
        );
      }
    } catch (e, st) {
      appLogger.e('[sync] failed: $e\n$st');
      // 진단용 흔적. 다음 부팅에서 "왜 데이터가 비어 보이는가" 추적 가능.
      try {
        await metaRepository.recordSyncError(e);
      } catch (_) {
        // 메타 기록조차 실패하면 무시한다. 본 로직은 throw 하지 않는다.
      }
      return SyncReport.failed(e);
    }

    // 신규 DailyStats 테이블이 v3 마이그레이션으로 생성된 직후, 기존 사용자의
    // SharedPreferences 오늘치를 1회 백필. marker 로 idempotent 보장.
    try {
      await dailyStatsRepository.bootstrapFromLocalStorage();
    } catch (e, st) {
      appLogger.w('[stats] backfill failed: $e\n$st');
    }
    return result;
  }

  Future<SyncReport> _syncFromPickedSource(
    _PickedSource source,
    Version sourceVersion,
  ) async {
    // 각 syncer 가 source 버전과 일치하는지 먼저 모두 판정.
    final upToDate = <bool>[];
    for (final s in syncers) {
      upToDate.add(await s.isUpToDate(sourceVersion));
    }

    if (upToDate.every((e) => e)) {
      appLogger.d('[sync] up-to-date @ $sourceVersion');
      return SyncReport.upToDate(sourceVersion);
    }

    // up-to-date 가 아닌 syncer 만 순서대로 재동기화.
    // (ExampleSentenceSyncer.syncFrom 은 내부에서 단어 JSON 도 함께 읽어
    //  cross-validate + ref persist 를 한 transaction 으로 처리한다.)
    for (var i = 0; i < syncers.length; i++) {
      if (upToDate[i]) continue;
      final s = syncers[i];
      appLogger.i(
          '[sync] ${s.dataKey} → $sourceVersion (source=${source.label})');
      await s.syncFrom(source: source.delegate, version: sourceVersion);
    }
    return SyncReport.synced(sourceVersion);
  }

  /// 원격 신버전이 있는지 확인. 네트워크 실패 시 null 반환.
  Future<Version?> probeRemoteVersion() async {
    try {
      final json = await remote.read(_versionKey);
      return VersionInfo.fromJson(json).version;
    } catch (e) {
      appLogger.w('[sync] remote version probe failed: $e');
      return null;
    }
  }

  /// 현재 로컬에서 sync 가능한 최신 source 버전 — `max(번들, 캐시)`.
  Future<Version> _resolveSourceVersion() async {
    final bundled = await _readVersion(bundle);
    final cached = await _readVersionFromCache();
    if (bundled == null && cached == null) {
      throw StateError('No bundled dataVersion available');
    }
    if (cached == null) return bundled!;
    if (bundled == null) return cached;
    return cached > bundled ? cached : bundled;
  }

  Future<Version?> _readVersion(JsonDataSource source) async {
    try {
      final json = await source.read(_versionKey);
      return VersionInfo.fromJson(json).version;
    } catch (e) {
      appLogger.w('[sync] failed to read version from source: $e');
      return null;
    }
  }

  Future<Version?> _readVersionFromCache() async {
    if (!await cache.exists(_versionKey)) return null;
    return _readVersion(cache);
  }

  /// 결정된 sourceVersion 과 일치하는 source 선택.
  ///
  /// 캐시 버전이 더 높으면 캐시, 아니면 번들.
  Future<_PickedSource> _pickSource(Version sourceVersion) async {
    final cached = await _readVersionFromCache();
    if (cached != null && cached == sourceVersion) {
      return _PickedSource(cache, 'cache');
    }
    return _PickedSource(bundle, 'bundle');
  }
}

class _PickedSource {
  _PickedSource(this.delegate, this.label);
  final JsonDataSource delegate;
  final String label;
}

/// 부팅 sync 결과. UI 게이트가 이걸 보고 분기.
sealed class SyncReport {
  const SyncReport();
  factory SyncReport.upToDate(Version v) = SyncReportUpToDate;
  factory SyncReport.synced(Version v) = SyncReportSynced;
  factory SyncReport.failed(Object error) = SyncReportFailed;

  bool get isOk => switch (this) {
        SyncReportUpToDate() || SyncReportSynced() => true,
        SyncReportFailed() => false,
      };
}

final class SyncReportUpToDate extends SyncReport {
  const SyncReportUpToDate(this.version);
  final Version version;
}

final class SyncReportSynced extends SyncReport {
  const SyncReportSynced(this.version);
  final Version version;
}

final class SyncReportFailed extends SyncReport {
  const SyncReportFailed(this.error);
  final Object error;
}
