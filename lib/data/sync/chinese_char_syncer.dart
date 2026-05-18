import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/chinese_char_repository.dart';
import 'package:jlpt_app/data/sync/json_entity_syncer.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:pub_semver/pub_semver.dart';

final class ChineseCharSyncer extends JsonEntitySyncer<ChineseChar> {
  ChineseCharSyncer({
    required this.charRepository,
    required this.metaRepository,
    required super.bundle,
    required super.cache,
    this.expectedMinRowCount = 1500,
  }) : super(dataKey: 'chinese_chars');

  final ChineseCharRepository charRepository;
  final AppMetaRepository metaRepository;

  /// 번들 한자 약 1892개. 안전마진 80%. 테스트는 작은 값으로 override.
  @override
  final int expectedMinRowCount;

  @override
  List<ChineseChar> parse(Map<String, dynamic> json) {
    final list = json['chars'];
    if (list is! List) {
      throw const FormatException("chinese_chars: missing 'chars' array");
    }
    // PK 가 char 하나뿐인 단일 컬럼이라 SQLite `INSERT OR REPLACE` 가 마지막 row 로
    // 덮어쓴다. 메모리 단계에서도 같은 정책으로 통일 — 데이터 입력 오류로 같은
    // 한자가 두 번 들어와도 앱이 안 켜지는 일은 없게 한다.
    final byChar = <String, ChineseChar>{};
    var conflicts = 0;
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      if (e is! Map<String, dynamic>) {
        throw FormatException('chars[$i] is not a JSON object');
      }
      final c = ChineseChar.fromJson(e);
      if (c.char.isEmpty) {
        throw FormatException('chars[$i] empty char');
      }
      final prev = byChar[c.char];
      if (prev != null && !_sameContent(prev, c)) {
        conflicts++;
      }
      byChar[c.char] = c;
    }
    if (conflicts > 0) {
      appLogger.w(
        '[chars] 내용이 다른 중복 $conflicts건 — 마지막 row 가 우선합니다',
      );
    }
    return byChar.values.toList(growable: false);
  }

  bool _sameContent(ChineseChar a, ChineseChar b) =>
      a.koreanChar == b.koreanChar &&
      _listEq(a.soundReading, b.soundReading) &&
      _listEq(a.meanReading, b.meanReading);

  bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Future<void> persist(List<ChineseChar> items, Version version) {
    return charRepository.syncAll(items, version: version);
  }

  @override
  Future<Version?> currentDbVersion() => metaRepository.getCharsVersion();

  @override
  Future<int> currentDbRowCount() => charRepository.countChars();
}
