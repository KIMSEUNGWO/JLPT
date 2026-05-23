import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:pub_semver/pub_semver.dart';

class WordRepository {
  final AppDatabase _db;
  final AppMetaRepository _meta;

  WordRepository(this._db, this._meta);

  Future<List<Word>> getByLevel(Level level) async {
    final rows = await _db.wordDao.getByLevel(level.name);
    return rows.map(_toWord).toList(growable: false);
  }

  Future<Map<Level, List<Word>>> getAllByLevel() async {
    final rows = await _db.wordDao.getAll();
    final result = <Level, List<Word>>{};
    for (final row in rows) {
      final level = Level.valueOf(row.level);
      result.putIfAbsent(level, () => []).add(_toWord(row));
    }
    return result;
  }

  Future<List<Word>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await _db.wordDao.getByIds(ids);
    return rows.map(_toWord).toList(growable: false);
  }

  /// 콘텐츠는 upsert, 사용자 진행도(`isRead`/`wrongCnt`)는 보존.
  ///
  /// 단일 transaction 안에서 모든 row를 batch upsert + 메타 버전 commit.
  /// 실패 시 자동 rollback 되어 부분 commit이 발생하지 않는다.
  Future<void> syncAll(List<Word> words, {required Version version}) async {
    await _db.transaction(() async {
      final existing = {
        for (final r in await _db.wordDao.getAll()) r.id: r,
      };
      final companions = words
          .map(
            (w) => WordsCompanion(
              id: Value(w.id),
              level: Value(w.level.name),
              act: Value(w.act.name),
              word: Value(w.word),
              hiragana: Value(w.hiragana),
              korean: Value(w.korean),
              isRead: Value(existing[w.id]?.isRead ?? false),
              wrongCnt: Value(existing[w.id]?.wrongCnt ?? 0),
            ),
          )
          .toList(growable: false);

      await _db.wordDao.upsertAll(companions);
      await _meta.markWordsSynced(version);
    });
  }

  Future<void> markRead(int wordId) => _db.wordDao.markRead(wordId);

  Future<void> markAllRead(List<int> wordIds) =>
      _db.wordDao.markAllRead(wordIds);

  Future<void> resetReadFor(Level level) =>
      _db.wordDao.resetReadForLevel(level.name);

  Future<bool> hasWords() => _db.wordDao.hasWords();

  Future<int> countWords() => _db.wordDao.countWords();

  /// DB readback. 예문 ID 목록은 ref 테이블에서 별도로 조회하므로 빈 리스트.
  /// 예문이 필요하면 `exampleSentencesByWordProvider(word.id)` 를 사용한다.
  Word _toWord(WordData row) => Word(
        id: row.id,
        level: Level.valueOf(row.level),
        act: Act.valueOf(row.act),
        word: row.word,
        hiragana: row.hiragana,
        korean: row.korean,
        isRead: row.isRead,
        wrongCnt: row.wrongCnt,
        exampleIds: const [],
      );

  // JSON 직렬화 헬퍼
  static List<int> decodeIds(String json) =>
      (jsonDecode(json) as List).cast<int>();

  static String encodeIds(List<int> ids) => jsonEncode(ids);
}
