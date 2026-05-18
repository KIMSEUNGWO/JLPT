import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/data/remote/json_data_source.dart';
import 'package:jlpt_app/data/sync/chinese_char_syncer.dart';
import 'package:jlpt_app/data/sync/data_sync_service.dart';
import 'package:jlpt_app/data/sync/word_syncer.dart';
import 'package:jlpt_app/initdata/update/version_info.dart';
import 'package:pub_semver/pub_semver.dart';

/// 원격 신버전을 다운로드 → 검증 → 캐시에 atomic 저장 → DB 적용까지 한 흐름으로 묶는다.
///
/// 흐름:
/// 1. `dataVersion` 원격 fetch → 로컬 sync 완료 버전과 비교
/// 2. `chinese_chars`, `japanese_words` 원격 fetch
/// 3. **메모리에서** 전체 DTO 파싱 + 검증 (한 row라도 실패하면 중단)
/// 4. 검증된 raw JSON 을 `documents/json/<name>.json` 에 atomic rename
/// 5. 같은 버전으로 syncer.persist 호출 (DB transaction)
///
/// 4단계까지 가지 않으면 디스크/DB는 절대 변경되지 않는다.
class UpdateService {
  UpdateService({
    required this.remote,
    required this.cache,
    required this.wordSyncer,
    required this.charSyncer,
    required this.dataSyncService,
  });

  final RemoteJsonDataSource remote;
  final LocalJsonCacheSource cache;
  final WordSyncer wordSyncer;
  final ChineseCharSyncer charSyncer;
  final DataSyncService dataSyncService;

  /// 업데이트가 가능한 경우 신버전을 반환. 동일/구버전이면 null.
  Future<UpdatePlan?> checkForUpdate() async {
    final remoteVersion = await dataSyncService.probeRemoteVersion();
    if (remoteVersion == null) return null;

    final currentWord = await wordSyncer.currentDbVersion();
    final currentChar = await charSyncer.currentDbVersion();
    final localMax = _maxVersion(currentWord, currentChar);
    if (localMax != null && remoteVersion <= localMax) return null;

    final size = await _estimateSize();
    return UpdatePlan(version: remoteVersion, estimatedBytes: size);
  }

  /// 다운로드 + 검증 + 적용. 진행 콜백은 단순 단계 카운터.
  ///
  /// 실패 시 throw — 호출 측에서 catch.
  Future<void> applyUpdate(
    UpdatePlan plan, {
    void Function(UpdateStage stage)? onStage,
  }) async {
    onStage?.call(UpdateStage.fetching);
    final rawVersion = await remote.read('dataVersion');
    final rawChars = await remote.read('chinese_chars');
    final rawWords = await remote.read('japanese_words');

    // 버전 cross-check: 다운로드 도중 서버에서 또 올라가지 않았는지.
    final fetchedVersion = VersionInfo.fromJson(rawVersion).version;
    if (fetchedVersion != plan.version) {
      throw StateError(
        '[update] version mismatch during fetch: '
        'plan=${plan.version}, actual=$fetchedVersion',
      );
    }

    onStage?.call(UpdateStage.validating);
    // 전체 파싱 시뮬레이션. 한 row 라도 실패하면 여기서 throw → 디스크 미반영.
    final words = wordSyncer.parse(rawWords);
    final chars = charSyncer.parse(rawChars);
    appLogger.i(
      '[update] validated: words=${words.length}, chars=${chars.length}, '
      'version=$fetchedVersion',
    );

    onStage?.call(UpdateStage.persistingFiles);
    // 검증 통과 후 atomic write. tmp → rename 으로 동일 디렉터리 내 원자성.
    await cache.writeAtomic('chinese_chars', rawChars);
    await cache.writeAtomic('japanese_words', rawWords);
    await cache.writeAtomic('dataVersion', rawVersion);

    onStage?.call(UpdateStage.persistingDb);
    // DB transaction 안에서 데이터 + 메타 commit. 부분 실패 없음.
    await charSyncer.persist(chars, fetchedVersion);
    await wordSyncer.persist(words, fetchedVersion);

    onStage?.call(UpdateStage.done);
  }

  Future<int> _estimateSize() async {
    final s1 = await remote.contentLength('dataVersion');
    final s2 = await remote.contentLength('chinese_chars');
    final s3 = await remote.contentLength('japanese_words');
    return s1 + s2 + s3;
  }

  Version? _maxVersion(Version? a, Version? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a > b ? a : b;
  }
}

class UpdatePlan {
  const UpdatePlan({required this.version, required this.estimatedBytes});
  final Version version;
  final int estimatedBytes;
}

enum UpdateStage {
  fetching,
  validating,
  persistingFiles,
  persistingDb,
  done,
}
