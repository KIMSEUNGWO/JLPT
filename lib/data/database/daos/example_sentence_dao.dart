import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/database/tables/example_sentences_table.dart';
import 'package:jlpt_app/data/database/tables/word_example_refs_table.dart';

part 'example_sentence_dao.g.dart';

@DriftAccessor(tables: [ExampleSentences, WordExampleRefs])
class ExampleSentenceDao extends DatabaseAccessor<AppDatabase>
    with _$ExampleSentenceDaoMixin {
  ExampleSentenceDao(super.db);

  Future<List<ExampleSentenceData>> getAll() => select(exampleSentences).get();

  /// 한 단어가 참조하는 예문들을 join 으로 조회.
  Future<List<ExampleSentenceData>> getByWordId(int wordId) {
    final q = select(exampleSentences).join([
      innerJoin(
        wordExampleRefs,
        wordExampleRefs.exampleId.equalsExp(exampleSentences.id),
      ),
    ])
      ..where(wordExampleRefs.wordId.equals(wordId));
    return q.map((row) => row.readTable(exampleSentences)).get();
  }

  /// 한 단어의 예문 id 만 (UI 가 본문은 자체 cache 에서 가져갈 때).
  Future<List<int>> getExampleIdsForWord(int wordId) async {
    final rows = await (select(wordExampleRefs)
          ..where((t) => t.wordId.equals(wordId)))
        .get();
    return rows.map((r) => r.exampleId).toList(growable: false);
  }

  Future<void> upsertExamples(List<ExampleSentencesCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(exampleSentences, rows));
  }

  /// 전체 ref 를 source 기준으로 교체 — 부분 단어 sync 가 없으므로 atomic 교체로 안전.
  Future<void> replaceAllRefs(List<WordExampleRefsCompanion> rows) async {
    await delete(wordExampleRefs).go();
    await batch((b) => b.insertAll(wordExampleRefs, rows));
  }

  Future<int> countExamples() async {
    final c = countAll();
    final row =
        await (selectOnly(exampleSentences)..addColumns([c])).getSingle();
    return row.read(c) ?? 0;
  }

  Future<int> countRefs() async {
    final c = countAll();
    final row =
        await (selectOnly(wordExampleRefs)..addColumns([c])).getSingle();
    return row.read(c) ?? 0;
  }
}
