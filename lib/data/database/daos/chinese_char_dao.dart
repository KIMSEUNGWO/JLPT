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
