import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/data/remote/json_data_source.dart';
import 'package:jlpt_app/data/sync/course_sync_bundle.dart';
import 'package:jlpt_app/data/sync/chinese_char_syncer.dart';
import 'package:jlpt_app/data/sync/data_sync_service.dart';
import 'package:jlpt_app/data/sync/example_sentence_syncer.dart';
import 'package:jlpt_app/data/sync/word_syncer.dart';
import 'package:jlpt_app/domain/course/course_data_config.dart';
import 'package:jlpt_app/initdata/update/version_info.dart';
import 'package:pub_semver/pub_semver.dart';

/// 원격 신버전을 다운로드 → 검증 → 캐시에 atomic 저장 → DB 적용까지 한 흐름으로 묶는다.
///
/// 흐름:
/// 1. 버전 JSON 원격 fetch → 로컬 sync 완료 버전과 비교
/// 2. 단어/(문자)/예문 JSON 원격 fetch
/// 3. **메모리에서** 전체 DTO 파싱 + 검증 (한 row라도 실패하면 중단)
/// 4. 검증된 raw JSON 을 `documents/json/<name>.json` 에 atomic rename
/// 5. 같은 버전으로 syncer.persist 호출 (DB transaction)
///
/// 4단계까지 가지 않으면 디스크/DB는 절대 변경되지 않는다.
///
/// 모든 데이터 키는 활성 course 의 [CourseDataConfig] 에서 가져오며, 문자 모듈이
/// 없는 코스는 [charSyncer] 가 null 이다.
class UpdateService {
  UpdateService({
    required this.syncBundle,
    required this.remote,
    required this.cache,
    required this.dataSyncService,
  });

  final CourseSyncBundle syncBundle;
  final RemoteJsonDataSource remote;
  final LocalJsonCacheSource cache;
  final DataSyncService dataSyncService;

  CourseDataConfig get _src => syncBundle.data;
  WordSyncer get wordSyncer => syncBundle.wordSyncer;
  ChineseCharSyncer? get charSyncer => syncBundle.charSyncer;
  ExampleSentenceSyncer get exampleSyncer => syncBundle.exampleSyncer;

  /// 업데이트가 가능한 경우 신버전을 반환. 동일/구버전이면 null.
  Future<UpdatePlan?> checkForUpdate() async {
    final remoteVersion = await dataSyncService.probeRemoteVersion();
    if (remoteVersion == null) return null;

    final currentVersions = <Version?>[
      for (final syncer in syncBundle.syncers) await syncer.currentDbVersion(),
    ];
    final alreadyApplied = currentVersions.every(
      (version) => version != null && version >= remoteVersion,
    );
    if (alreadyApplied) return null;

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
    final charsKey = _src.charsKey;
    final hasChars = charSyncer != null && charsKey != null;

    onStage?.call(UpdateStage.fetching);
    final rawVersion = await remote.read(_src.versionKey);
    final rawWords = await remote.read(_src.wordsKey);
    final rawExamples = await remote.read(_src.examplesKey);
    final rawChars = hasChars ? await remote.read(charsKey) : null;

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
    final examples = exampleSyncer.parse(rawExamples);
    final chars = hasChars ? charSyncer!.parse(rawChars!) : null;
    final refs = exampleSyncer.buildAndValidateRefs(words, examples);
    appLogger.i(
      '[update] validated: words=${words.length}, '
      'chars=${chars?.length ?? 0}, examples=${examples.length}, '
      'refs=${refs.length}, version=$fetchedVersion',
    );

    onStage?.call(UpdateStage.persistingFiles);
    // 검증 통과 후 atomic write. tmp → rename 으로 동일 디렉터리 내 원자성.
    if (hasChars) await cache.writeAtomic(charsKey, rawChars!);
    await cache.writeAtomic(_src.wordsKey, rawWords);
    await cache.writeAtomic(_src.examplesKey, rawExamples);
    await cache.writeAtomic(_src.versionKey, rawVersion);

    onStage?.call(UpdateStage.persistingDb);
    // DB transaction 안에서 데이터 + 메타 commit. 부분 실패 없음.
    if (hasChars) await charSyncer!.persist(chars!, fetchedVersion);
    await wordSyncer.persist(words, fetchedVersion);
    // 예문 본문 + ref 를 한 트랜잭션으로 교체.
    await exampleSyncer.exampleRepository.syncAll(
      examples: examples,
      wordExampleRefs: refs,
      version: fetchedVersion,
    );

    onStage?.call(UpdateStage.done);
  }

  Future<int> _estimateSize() async {
    final charsKey = _src.charsKey;
    var total = 0;
    total += await remote.contentLength(_src.versionKey);
    total += await remote.contentLength(_src.wordsKey);
    total += await remote.contentLength(_src.examplesKey);
    if (charSyncer != null && charsKey != null) {
      total += await remote.contentLength(charsKey);
    }
    return total;
  }
}

class UpdatePlan {
  const UpdatePlan({required this.version, required this.estimatedBytes});
  final Version version;
  final int estimatedBytes;
}

enum UpdateStage { fetching, validating, persistingFiles, persistingDb, done }
