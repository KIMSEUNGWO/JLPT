import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/database/tables/chinese_chars_table.dart';

part 'chinese_char_dao.g.dart';

@DriftAccessor(tables: [ChineseChars])
class ChineseCharDao extends DatabaseAccessor<AppDatabase>
    with _$ChineseCharDaoMixin {
  ChineseCharDao(super.db);

  Future<List<ChineseCharData>> getAll() => select(chineseChars).get();

  Future<void> upsertAll(List<ChineseCharsCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(chineseChars, rows));
  }

  Future<bool> hasChars() async {
    final result =
        await (selectOnly(chineseChars)..addColumns([chineseChars.char])).get();
    return result.isNotEmpty;
  }
}
