import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/data/remote/json_data_source.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/example_sentence_repository.dart';
import 'package:jlpt_app/data/sync/json_entity_syncer.dart';
import 'package:jlpt_app/data/sync/word_json_parser.dart';
import 'package:jlpt_app/domain/example_sentence.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:pub_semver/pub_semver.dart';

/// 예문 본문 + 단어→예문 참조를 함께 동기화하는 Syncer.
///
/// 예문 본문은 `example_sentences.json`, 참조는 `japanese_words.json`에 들어있어
/// 두 JSON 을 같은 source 에서 함께 읽고 cross validation 후 한 transaction 으로
/// persist 한다.
final class ExampleSentenceSyncer extends JsonEntitySyncer<ExampleSentence> {
  ExampleSentenceSyncer({
    required this.exampleRepository,
    required this.metaRepository,
    required this.courseId,
    required this.wordsDataKey,
    required super.bundle,
    required super.cache,
    required super.dataKey,
    required this.expectedMinRowCount,
  });

  final ExampleSentenceRepository exampleRepository;
  final AppMetaRepository metaRepository;
  final String courseId;

  /// 단어 JSON 키 — 예문과 cross-validation 할 단어 데이터를 같은 source 에서 읽는다.
  final String wordsDataKey;

  /// 정상으로 간주할 최소 예문 수. 코스 데이터 규모에 맞춰 주입된다.
  @override
  final int expectedMinRowCount;

  @override
  List<ExampleSentence> parse(Map<String, dynamic> json) {
    final list = json['examples'];
    if (list is! List) {
      throw const FormatException(
        "example_sentences: missing 'examples' array",
      );
    }
    final result = <ExampleSentence>[];
    final byId = <int, ExampleSentence>{};
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      if (e is! Map<String, dynamic>) {
        throw FormatException('examples[$i] is not a JSON object');
      }
      final ex = ExampleSentence.fromJson(e);
      if (byId.containsKey(ex.id)) {
        throw FormatException('examples[$i] id=${ex.id} 중복 — 같은 id 는 유일해야 한다');
      }
      byId[ex.id] = ex;
      result.add(ex);
    }
    return result;
  }

  /// 기본 [persist] 는 ref 없이 본문만 저장하므로 [syncFrom] 에서 직접
  /// `exampleRepository.syncAll(examples, refs, version)` 을 호출한다.
  @override
  Future<void> persist(List<ExampleSentence> items, Version version) {
    return exampleRepository.syncAll(
      examples: items,
      wordExampleRefs: const <int, List<int>>{},
      version: version,
    );
  }

  @override
  Future<Version?> currentDbVersion() =>
      metaRepository.getExamplesVersion(courseId);

  @override
  Future<int> currentDbRowCount() => exampleRepository.countExamples();

  /// 예문 + 단어 JSON 을 같은 source 에서 읽고 cross validation 후 한 번에 persist.
  ///
  /// 기본 구현 ([JsonEntitySyncer.syncFrom]) 은 단일 dataKey 만 다루므로 override.
  @override
  Future<void> syncFrom({
    required JsonDataSource source,
    required Version version,
  }) async {
    final rawExamples = await source.read(dataKey);
    final examples = parse(rawExamples);
    if (examples.length < expectedMinRowCount) {
      throw StateError(
        '[$dataKey] sync aborted: parsed ${examples.length} rows '
        '< expectedMinRowCount=$expectedMinRowCount',
      );
    }

    final rawWords = await source.read(wordsDataKey);
    final words = parseWordsJson(rawWords);

    final refs = buildAndValidateRefs(words, examples);

    appLogger.i(
      '[example_sentences] cross-validated: examples=${examples.length}, '
      'refs=${refs.length} → persist @ $version',
    );

    await exampleRepository.syncAll(
      examples: examples,
      wordExampleRefs: refs,
      version: version,
    );
  }

  /// 단어가 참조하는 모든 예문 id 가 examples 안에 실재하는지 확인하고
  /// `{wordId: [exampleIds...]}` map 으로 환원.
  Map<int, List<int>> buildAndValidateRefs(
    List<Word> words,
    List<ExampleSentence> examples,
  ) {
    final exampleIdSet = {for (final e in examples) e.id};
    final refs = <int, List<int>>{};
    for (final w in words) {
      for (final eid in w.exampleIds) {
        if (!exampleIdSet.contains(eid)) {
          throw FormatException(
            'word(id=${w.id}) 가 존재하지 않는 예문 id=$eid 를 참조합니다',
          );
        }
      }
      refs[w.id] = w.exampleIds;
    }
    return refs;
  }
}
