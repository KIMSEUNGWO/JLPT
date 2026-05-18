import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/data/sync/json_entity_syncer.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:pub_semver/pub_semver.dart';

final class WordSyncer extends JsonEntitySyncer<Word> {
  WordSyncer({
    required this.wordRepository,
    required this.metaRepository,
    required super.bundle,
    required super.cache,
    this.expectedMinRowCount = 1800,
  }) : super(dataKey: 'japanese_words');

  final WordRepository wordRepository;
  final AppMetaRepository metaRepository;

  /// N1~N5 합산 약 2200개. 안전마진을 두고 80% 까지 허용. 미만이면 부분 DB / 손상으로 간주.
  /// 테스트에서 fixture 크기에 맞게 낮출 수 있도록 생성자에서 주입 가능.
  @override
  final int expectedMinRowCount;

  @override
  List<Word> parse(Map<String, dynamic> json) {
    final list = json['words'];
    if (list is! List) {
      throw const FormatException("words: missing 'words' array");
    }
    final result = <Word>[];
    final byId = <int, Word>{};
    var sameContentDups = 0;
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      if (e is! Map<String, dynamic>) {
        throw FormatException('words[$i] is not a JSON object');
      }
      final word = Word.fromJson(e);
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
          '기존="${existing.word}/${existing.korean}" '
          '신규="${word.word}/${word.korean}"',
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
      a.level == b.level &&
      a.act == b.act &&
      a.word == b.word &&
      a.hiragana == b.hiragana &&
      a.korean == b.korean;

  @override
  Future<void> persist(List<Word> items, Version version) {
    return wordRepository.syncAll(items, version: version);
  }

  @override
  Future<Version?> currentDbVersion() => metaRepository.getWordsVersion();

  @override
  Future<int> currentDbRowCount() => wordRepository.countWords();
}
