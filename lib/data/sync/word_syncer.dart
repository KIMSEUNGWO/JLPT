import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/data/sync/json_entity_syncer.dart';
import 'package:jlpt_app/data/sync/word_json_parser.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:pub_semver/pub_semver.dart';

final class WordSyncer extends JsonEntitySyncer<Word> {
  WordSyncer({
    required this.wordRepository,
    required this.metaRepository,
    required this.courseId,
    required super.bundle,
    required super.cache,
    required super.dataKey,
    required this.expectedMinRowCount,
  });

  final WordRepository wordRepository;
  final AppMetaRepository metaRepository;
  final String courseId;

  /// 정상으로 간주할 최소 단어 수. 미만이면 부분 DB / 손상으로 간주.
  /// 코스 데이터 규모에 맞춰 주입된다.
  @override
  final int expectedMinRowCount;

  @override
  List<Word> parse(Map<String, dynamic> json) {
    final list = parseWordsJson(json);
    final result = <Word>[];
    final byId = <int, Word>{};
    var sameContentDups = 0;
    for (var i = 0; i < list.length; i++) {
      final word = list[i];
      final existing = byId[word.id];
      if (existing != null) {
        // 같은 id + 같은 내용 = 입력 데이터의 무해한 중복. 첫 번째만 채택.
        // 같은 id + 다른 내용 = 진짜 충돌. 어느 게 정답인지 모르므로 거부.
        if (_sameContent(existing, word)) {
          sameContentDups++;
          continue;
        }
        throw FormatException(
          'words[$i] id=${word.id} 충돌: '
          '기존="${existing.word}/${existing.meaning}" '
          '신규="${word.word}/${word.meaning}"',
        );
      }
      byId[word.id] = word;
      result.add(word);
    }
    if (sameContentDups > 0) {
      appLogger.w('[words] 동일 내용 중복 $sameContentDups건 무시');
    }
    return result;
  }

  bool _sameContent(Word a, Word b) =>
      a.levelCode == b.levelCode &&
      a.act == b.act &&
      a.word == b.word &&
      a.reading == b.reading &&
      a.meaning == b.meaning;

  @override
  Future<void> persist(List<Word> items, Version version) {
    return wordRepository.syncAll(items, version: version);
  }

  @override
  Future<Version?> currentDbVersion() =>
      metaRepository.getWordsVersion(courseId);

  @override
  Future<int> currentDbRowCount() => wordRepository.countWords();
}
