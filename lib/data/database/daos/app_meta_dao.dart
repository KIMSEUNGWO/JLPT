import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/database/tables/app_meta_table.dart';

part 'app_meta_dao.g.dart';

@DriftAccessor(tables: [AppMeta])
class AppMetaDao extends DatabaseAccessor<AppDatabase> with _$AppMetaDaoMixin {
  AppMetaDao(super.db);

  Future<String?> get(String key) async {
    final row = await (select(appMeta)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<Map<String, String>> getAll() async {
    final rows = await select(appMeta).get();
    return {for (final r in rows) r.key: r.value};
  }

  Future<void> put(String key, String value) async {
    await into(appMeta).insertOnConflictUpdate(
      AppMetaCompanion(key: Value(key), value: Value(value)),
    );
  }

  Future<void> remove(String key) async {
    await (delete(appMeta)..where((t) => t.key.equals(key))).go();
  }
}
