import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/data/remote/json_data_source.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/example_sentence_repository.dart';
import 'package:jlpt_app/data/sync/json_entity_syncer.dart';
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
    required super.bundle,
    required super.cache,
    this.expectedMinRowCount = 2000,
  }) : super(dataKey: 'example_sentences');

  final ExampleSentenceRepository exampleRepository;
  final AppMetaRepository metaRepository;

  /// 전체 2150 단어 + default(id=0) = 2151. 안전 마진으로 2000.
  /// 테스트에서 fixture 크기에 맞게 override.
  @override
  final int expectedMinRowCount;

  @override
  List<ExampleSentence> parse(Map<String, dynamic> json) {
    final list = json['examples'];
    if (list is! List) {
      throw const FormatException("example_sentences: missing 'examples' array");
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
        throw FormatException(
          'examples[$i] id=${ex.id} 중복 — 같은 id 는 유일해야 한다',
        );
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
  Future<Version?> currentDbVersion() => metaRepository.getExamplesVersion();

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

    final rawWords = await source.read('japanese_words');
    final wordsList = rawWords['words'];
    if (wordsList is! List) {
      throw const FormatException(
        "example_sentences cross-validation: 'words' array missing",
      );
    }

    final exampleIdSet = {for (final e in examples) e.id};
    final refs = <int, List<int>>{};
    for (var i = 0; i < wordsList.length; i++) {
      final raw = wordsList[i];
      if (raw is! Map<String, dynamic>) {
        throw FormatException('words[$i] is not a JSON object');
      }
      // Word.fromJson 이 exampleIds 의 존재/타입을 이미 검증.
      final w = Word.fromJson(raw);
      for (final eid in w.exampleIds) {
        if (!exampleIdSet.contains(eid)) {
          throw FormatException(
            'word(id=${w.id}) 가 존재하지 않는 예문 id=$eid 를 참조합니다',
          );
        }
      }
      refs[w.id] = w.exampleIds;
    }

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
}
