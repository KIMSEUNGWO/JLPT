import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/database/tables/words_table.dart';

part 'word_dao.g.dart';

@DriftAccessor(tables: [Words])
class WordDao extends DatabaseAccessor<AppDatabase> with _$WordDaoMixin {
  WordDao(super.db);

  Future<List<WordData>> getByLevel(String course, String level) => (select(
    words,
  )..where((t) => t.course.equals(course) & t.level.equals(level))).get();

  Future<List<WordData>> getAll(String course) =>
      (select(words)..where((t) => t.course.equals(course))).get();

  Future<List<WordData>> getByIds(String course, List<int> ids) => (select(
    words,
  )..where((t) => t.course.equals(course) & t.id.isIn(ids))).get();

  Future<void> upsertAll(List<WordsCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(words, rows));
  }

  /// [keepIds] 에 없는 코스 단어를 삭제한다 — 원격 데이터에서 빠진 단어를
  /// DB 에서도 제거해 upsert-only 로 인한 고아 row 누적을 막는다.
  /// (WordExampleRefs 는 (course,id) FK ON DELETE CASCADE 로 함께 정리된다.)
  Future<int> deleteNotIn(String course, List<int> keepIds) =>
      (delete(words)
            ..where((t) => t.course.equals(course) & t.id.isNotIn(keepIds)))
          .go();

  Future<void> markRead(String course, int id) =>
      (update(words)..where((t) => t.course.equals(course) & t.id.equals(id)))
          .write(const WordsCompanion(isRead: Value(true)));

  Future<void> markAllRead(String course, List<int> ids) =>
      (update(words)..where((t) => t.course.equals(course) & t.id.isIn(ids)))
          .write(const WordsCompanion(isRead: Value(true)));

  Future<void> resetReadForLevel(String course, String level) =>
      (update(words)
            ..where((t) => t.course.equals(course) & t.level.equals(level)))
          .write(const WordsCompanion(isRead: Value(false)));

  /// 코스 전체 단어의 학습 진도(읽음/오답 수)를 초기화한다.
  Future<void> resetAllRead(String course) =>
      (update(words)..where((t) => t.course.equals(course))).write(
        const WordsCompanion(isRead: Value(false), wrongCnt: Value(0)),
      );

  /// row count. 부분 DB 감지에 사용.
  Future<int> countWords(String course) async {
    final c = countAll();
    final row =
        await (selectOnly(words)
              ..addColumns([c])
              ..where(words.course.equals(course)))
            .getSingle();
    return row.read(c) ?? 0;
  }
}
