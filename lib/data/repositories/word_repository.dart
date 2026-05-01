import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';

class WordRepository {
  final AppDatabase _db;

  WordRepository(this._db);

  Future<List<Word>> getByLevel(Level level) async {
    final rows = await _db.wordDao.getByLevel(level.name);
    return rows.map(_toWord).toList();
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
    if (ids.isEmpty) return [];
    final rows = await _db.wordDao.getByIds(ids);
    return rows.map(_toWord).toList();
  }

  Future<void> syncAll(List<Word> words) async {
    final companions = words.map((w) => WordsCompanion(
          id: Value(w.id),
          level: Value(w.level.name),
          act: Value(w.act.name),
          word: Value(w.word),
          hiragana: Value(w.hiragana),
          korean: Value(w.korean),
          isRead: const Value(false),
          wrongCnt: const Value(0),
        ));

    // upsert: 기존 단어는 내용을 업데이트하되 isRead/wrongCnt는 유지
    await _db.transaction(() async {
      final existing = {
        for (final r in await _db.wordDao.getAll()) r.id: r
      };
      final toInsert = <WordsCompanion>[];
      final toUpdate = <WordsCompanion>[];

      for (final c in companions) {
        final id = c.id.value;
        if (existing.containsKey(id)) {
          toUpdate.add(WordsCompanion(
            id: Value(id),
            level: c.level,
            act: c.act,
            word: c.word,
            hiragana: c.hiragana,
            korean: c.korean,
            isRead: Value(existing[id]!.isRead),
            wrongCnt: Value(existing[id]!.wrongCnt),
          ));
        } else {
          toInsert.add(c);
        }
      }

      if (toInsert.isNotEmpty) {
        await _db.batch(
            (b) => b.insertAllOnConflictUpdate(_db.words, toInsert));
      }
      for (final row in toUpdate) {
        await (_db.update(_db.words)..where((t) => t.id.equals(row.id.value)))
            .write(row);
      }
    });
  }

  Future<void> markRead(int wordId) => _db.wordDao.markRead(wordId);

  Future<void> markAllRead(List<int> wordIds) =>
      _db.wordDao.markAllRead(wordIds);

  Future<void> resetReadFor(Level level) =>
      _db.wordDao.resetReadForLevel(level.name);

  Future<bool> hasWords() => _db.wordDao.hasWords();

  Word _toWord(WordData row) => Word(
        id: row.id,
        level: Level.valueOf(row.level),
        act: Act.valueOf(row.act),
        word: row.word,
        hiragana: row.hiragana,
        korean: row.korean,
        isRead: row.isRead,
        wrongCnt: row.wrongCnt,
      );

  // JSON 직렬화 헬퍼
  static List<int> decodeIds(String json) =>
      (jsonDecode(json) as List).cast<int>();

  static String encodeIds(List<int> ids) => jsonEncode(ids);
}
