import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:pub_semver/pub_semver.dart';

typedef LevelResolver = Level? Function(String code);

/// 단어 저장소. 활성 course id 에 스코프된다 — 모든 read/write 가 `course` 컬럼으로
/// 필터/태깅되며, 물리 컬럼 `hiragana`/`korean` 을 도메인의 `reading`/`meaning` 으로
/// 매핑한다 (컬럼 rename 비용 회피).
class WordRepository {
  final AppDatabase _db;
  final AppMetaRepository _meta;
  final String _courseId;
  final LevelResolver _levelOf;

  WordRepository(
    this._db,
    this._meta, {
    required String courseId,
    required LevelResolver levelOf,
  }) : _courseId = courseId,
       _levelOf = levelOf;

  Future<List<Word>> getByLevel(Level level) async {
    return getByLevelCode(level.code);
  }

  Future<List<Word>> getByLevelCode(String levelCode) async {
    final rows = await _db.wordDao.getByLevel(_courseId, levelCode);
    return rows.map(_toWord).toList(growable: false);
  }

  Future<Map<Level, List<Word>>> getAllByLevel() async {
    final rows = await _db.wordDao.getAll(_courseId);
    final result = <Level, List<Word>>{};
    for (final row in rows) {
      final level = _levelOf(row.level);
      if (level == null) continue; // 활성 코스에 없는 레벨 코드는 무시.
      result.putIfAbsent(level, () => []).add(_toWord(row));
    }
    return result;
  }

  Future<List<Word>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await _db.wordDao.getByIds(_courseId, ids);
    return rows.map(_toWord).toList(growable: false);
  }

  /// 콘텐츠는 upsert, 사용자 진행도(`isRead`/`wrongCnt`)는 보존.
  ///
  /// 단일 transaction 안에서 모든 row를 batch upsert + 메타 버전 commit.
  /// 실패 시 자동 rollback 되어 부분 commit이 발생하지 않는다.
  Future<void> syncAll(List<Word> words, {required Version version}) async {
    await _db.transaction(() async {
      final existing = {
        for (final r in await _db.wordDao.getAll(_courseId)) r.id: r,
      };
      final companions = words
          .map(
            (w) => WordsCompanion(
              id: Value(w.id),
              course: Value(_courseId),
              level: Value(w.levelCode),
              act: Value(w.act.name),
              word: Value(w.word),
              hiragana: Value(w.reading ?? ''),
              korean: Value(w.meaning),
              isRead: Value(existing[w.id]?.isRead ?? false),
              wrongCnt: Value(existing[w.id]?.wrongCnt ?? 0),
            ),
          )
          .toList(growable: false);

      await _db.wordDao.upsertAll(companions);
      await _meta.markWordsSynced(version, _courseId);
    });
  }

  Future<void> markRead(int wordId) => _db.wordDao.markRead(_courseId, wordId);

  Future<void> markAllRead(List<int> wordIds) =>
      _db.wordDao.markAllRead(_courseId, wordIds);

  Future<void> resetReadFor(Level level) =>
      _db.wordDao.resetReadForLevel(_courseId, level.code);

  Future<int> countWords() => _db.wordDao.countWords(_courseId);

  /// DB readback. 예문 ID 목록은 ref 테이블에서 별도로 조회하므로 빈 리스트.
  /// 예문이 필요하면 `exampleSentencesByWordProvider(word.id)` 를 사용한다.
  Word _toWord(WordData row) => Word(
    id: row.id,
    levelCode: row.level,
    act: Act.valueOf(row.act),
    word: row.word,
    reading: row.hiragana.isEmpty ? null : row.hiragana,
    meaning: row.korean,
    isRead: row.isRead,
    wrongCnt: row.wrongCnt,
    exampleIds: const [],
  );

  // JSON 직렬화 헬퍼
  static List<int> decodeIds(String json) =>
      (jsonDecode(json) as List).cast<int>();
}
