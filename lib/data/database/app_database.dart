import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:jlpt_app/data/database/daos/chinese_char_dao.dart';
import 'package:jlpt_app/data/database/daos/test_result_dao.dart';
import 'package:jlpt_app/data/database/daos/word_dao.dart';
import 'package:jlpt_app/data/database/tables/chinese_chars_table.dart';
import 'package:jlpt_app/data/database/tables/test_questions_table.dart';
import 'package:jlpt_app/data/database/tables/test_results_table.dart';
import 'package:jlpt_app/data/database/tables/words_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Words, ChineseChars, TestResults, TestQuestions],
  daos: [WordDao, ChineseCharDao, TestResultDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'jlpt_go.db'));
    return NativeDatabase.createInBackground(file);
  });
}
