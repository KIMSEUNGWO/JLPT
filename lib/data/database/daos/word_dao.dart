import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/database/tables/words_table.dart';

part 'word_dao.g.dart';

@DriftAccessor(tables: [Words])
class WordDao extends DatabaseAccessor<AppDatabase> with _$WordDaoMixin {
  WordDao(super.db);

  Future<List<WordData>> getByLevel(String level) =>
      (select(words)..where((t) => t.level.equals(level))).get();

  Future<List<WordData>> getAll() => select(words).get();

  Future<List<WordData>> getByIds(List<int> ids) =>
      (select(words)..where((t) => t.id.isIn(ids))).get();

  Future<void> upsertAll(List<WordsCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(words, rows));
  }

  Future<void> markRead(int id) =>
      (update(words)..where((t) => t.id.equals(id)))
          .write(const WordsCompanion(isRead: Value(true)));

  Future<void> markAllRead(List<int> ids) =>
      (update(words)..where((t) => t.id.isIn(ids)))
          .write(const WordsCompanion(isRead: Value(true)));

  Future<void> resetReadForLevel(String level) =>
      (update(words)..where((t) => t.level.equals(level)))
          .write(const WordsCompanion(isRead: Value(false)));

  Future<bool> hasWords() async {
    final result = await (selectOnly(words)..addColumns([words.id])).get();
    return result.isNotEmpty;
  }
}
