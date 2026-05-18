import 'package:jlpt_app/data/remote/json_data_source.dart';
import 'package:pub_semver/pub_semver.dart';

/// 번들 / 캐시 / 원격에서 가져온 JSON을 검증 → DB로 동기화하는
/// 한 종류 데이터셋 (단어, 한자 …) 의 흐름을 추상화한다.
///
/// 구현체는 데이터셋별 차이만 채우면 된다:
/// - [dataKey]                : 'words' / 'chars' 등 — 메타 키, 파일명, 로그에 공통 사용
/// - [parse]                  : raw JSON → 도메인 엔티티 리스트
/// - [persist]                : 엔티티 리스트 → DB transaction (메타 commit 포함)
/// - [currentDbVersion]       : DB 메타가 기록한 최근 sync 완료 버전
/// - [currentDbRowCount]      : DB row 수 — 부분 DB 감지에 사용
/// - [expectedMinRowCount]    : 정상으로 간주할 최소 row 수
abstract base class JsonEntitySyncer<T> {
  JsonEntitySyncer({
    required this.dataKey,
    required this.bundle,
    required this.cache,
  });

  final String dataKey;
  final AssetJsonDataSource bundle;
  final LocalJsonCacheSource cache;

  List<T> parse(Map<String, dynamic> json);

  Future<void> persist(List<T> items, Version version);

  Future<Version?> currentDbVersion();

  Future<int> currentDbRowCount();

  int get expectedMinRowCount;

  /// "데이터셋이 source 버전과 정확히 일치하고, row 수가 정상 범위인가."
  ///
  /// 이 메서드가 false 라면 [syncFrom] 을 호출해 재동기화해야 한다.
  Future<bool> isUpToDate(Version sourceVersion) async {
    final dbVersion = await currentDbVersion();
    if (dbVersion == null) return false;
    if (dbVersion != sourceVersion) return false;
    final rows = await currentDbRowCount();
    return rows >= expectedMinRowCount;
  }

  /// 주어진 source 에서 데이터를 읽어 파싱→검증→persist 까지 수행.
  ///
  /// 파싱 또는 검증이 실패하면 예외를 던지며, DB 는 건드리지 않는다.
  /// [persist] 안에서 transaction 사용이 보장되므로 부분 commit 도 발생하지 않는다.
  Future<void> syncFrom({
    required JsonDataSource source,
    required Version version,
  }) async {
    final raw = await source.read(dataKey);
    final items = parse(raw);
    if (items.length < expectedMinRowCount) {
      throw StateError(
        '[$dataKey] sync aborted: parsed ${items.length} rows '
        '< expectedMinRowCount=$expectedMinRowCount',
      );
    }
    await persist(items, version);
  }
}
