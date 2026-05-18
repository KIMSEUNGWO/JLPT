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
    final result = <ChineseChar>[];
    final seenChars = <String>{};
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      if (e is! Map<String, dynamic>) {
        throw FormatException('chars[$i] is not a JSON object');
      }
      final c = ChineseChar.fromJson(e);
      if (c.char.isEmpty) {
        throw FormatException('chars[$i] empty char');
      }
      if (!seenChars.add(c.char)) {
        throw FormatException('chars[$i] duplicate char=${c.char}');
      }
      result.add(c);
    }
    return result;
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
