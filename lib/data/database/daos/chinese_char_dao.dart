import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/database/tables/chinese_chars_table.dart';

part 'chinese_char_dao.g.dart';

@DriftAccessor(tables: [ChineseChars])
class ChineseCharDao extends DatabaseAccessor<AppDatabase>
    with _$ChineseCharDaoMixin {
  ChineseCharDao(super.db);

  Future<List<ChineseCharData>> getAll(String course) =>
      (select(chineseChars)..where((t) => t.course.equals(course))).get();

  Future<void> upsertAll(List<ChineseCharsCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(chineseChars, rows));
  }

  /// [keepChars] 에 없는 코스 문자를 삭제한다 — 원격에서 빠진 문자를
  /// DB 에서도 제거해 upsert-only 로 인한 고아 row 누적을 막는다.
  Future<int> deleteNotIn(String course, List<String> keepChars) =>
      (delete(chineseChars)
            ..where(
              (t) => t.course.equals(course) & t.char.isNotIn(keepChars),
            ))
          .go();

  Future<int> countChars(String course) async {
    final c = countAll();
    final row =
        await (selectOnly(chineseChars)
              ..addColumns([c])
              ..where(chineseChars.course.equals(course)))
            .getSingle();
    return row.read(c) ?? 0;
  }
}
