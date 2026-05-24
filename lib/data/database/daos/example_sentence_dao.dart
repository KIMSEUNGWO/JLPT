import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/database/tables/example_sentences_table.dart';
import 'package:jlpt_app/data/database/tables/word_example_refs_table.dart';

part 'example_sentence_dao.g.dart';

@DriftAccessor(tables: [ExampleSentences, WordExampleRefs])
class ExampleSentenceDao extends DatabaseAccessor<AppDatabase>
    with _$ExampleSentenceDaoMixin {
  ExampleSentenceDao(super.db);

  Future<List<ExampleSentenceData>> getAll(String course) =>
      (select(exampleSentences)..where((t) => t.course.equals(course))).get();

  /// 한 단어가 참조하는 예문들을 join 으로 조회.
  Future<List<ExampleSentenceData>> getByWordId(String course, int wordId) {
    final q = select(exampleSentences).join([
      innerJoin(
        wordExampleRefs,
        wordExampleRefs.exampleId.equalsExp(exampleSentences.id),
      ),
    ])
      ..where(wordExampleRefs.wordId.equals(wordId) &
          exampleSentences.course.equals(course));
    return q.map((row) => row.readTable(exampleSentences)).get();
  }

  Future<void> upsertExamples(List<ExampleSentencesCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(exampleSentences, rows));
  }

  /// 한 코스의 ref 를 source 기준으로 교체 — 부분 단어 sync 가 없으므로 atomic 교체로 안전.
  Future<void> replaceAllRefs(
    String course,
    List<WordExampleRefsCompanion> rows,
  ) async {
    await (delete(wordExampleRefs)..where((t) => t.course.equals(course))).go();
    await batch((b) => b.insertAll(wordExampleRefs, rows));
  }

  Future<int> countExamples(String course) async {
    final c = countAll();
    final row = await (selectOnly(exampleSentences)
          ..addColumns([c])
          ..where(exampleSentences.course.equals(course)))
        .getSingle();
    return row.read(c) ?? 0;
  }

  Future<int> countRefs(String course) async {
    final c = countAll();
    final row = await (selectOnly(wordExampleRefs)
          ..addColumns([c])
          ..where(wordExampleRefs.course.equals(course)))
        .getSingle();
    return row.read(c) ?? 0;
  }
}
