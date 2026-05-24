import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/domain/example_sentence.dart';
import 'package:pub_semver/pub_semver.dart';

/// 예문 + (단어→예문) 참조 테이블을 묶어서 다루는 Repository.
///
/// 활성 course id 에 스코프된다. sync 시에는 두 테이블을 같은 transaction 으로
/// 교체하고 메타 버전을 commit 한다.
class ExampleSentenceRepository {
  final AppDatabase _db;
  final AppMetaRepository _meta;
  final String _courseId;

  ExampleSentenceRepository(this._db, this._meta, {required String courseId})
    : _courseId = courseId;

  Future<List<ExampleSentence>> getAll() async {
    final rows = await _db.exampleSentenceDao.getAll(_courseId);
    return rows.map(_toEntity).toList(growable: false);
  }

  /// 한 단어가 참조하는 예문 본문 목록.
  Future<List<ExampleSentence>> getByWordId(int wordId) async {
    final rows = await _db.exampleSentenceDao.getByWordId(_courseId, wordId);
    return rows.map(_toEntity).toList(growable: false);
  }

  /// 예문 본문 + 단어-예문 참조를 한 번에 교체.
  ///
  /// 트랜잭션 순서:
  /// 1. ExampleSentences upsert
  /// 2. WordExampleRefs 전체 교체 (source 기준)
  /// 3. examples_version 메타 commit
  Future<void> syncAll({
    required List<ExampleSentence> examples,
    required Map<int, List<int>> wordExampleRefs,
    required Version version,
  }) async {
    final exampleRows = examples
        .map(
          (e) => ExampleSentencesCompanion(
            id: Value(e.id),
            course: Value(_courseId),
            sentence: Value(e.sentence),
            translation: Value(e.translation),
          ),
        )
        .toList(growable: false);

    final refRows = <WordExampleRefsCompanion>[];
    for (final entry in wordExampleRefs.entries) {
      for (final exampleId in entry.value) {
        refRows.add(
          WordExampleRefsCompanion(
            course: Value(_courseId),
            wordId: Value(entry.key),
            exampleId: Value(exampleId),
          ),
        );
      }
    }

    await _db.transaction(() async {
      await _db.exampleSentenceDao.upsertExamples(exampleRows);
      await _db.exampleSentenceDao.replaceAllRefs(_courseId, refRows);
      await _meta.markExamplesSynced(version, _courseId);
    });
  }

  Future<int> countExamples() =>
      _db.exampleSentenceDao.countExamples(_courseId);

  ExampleSentence _toEntity(ExampleSentenceData row) => ExampleSentence(
    id: row.id,
    sentence: row.sentence,
    translation: row.translation,
  );
}
