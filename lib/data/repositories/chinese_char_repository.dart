import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/domain/chinese_char.dart';

class ChineseCharRepository {
  final AppDatabase _db;

  ChineseCharRepository(this._db);

  Future<Map<String, ChineseChar>> getAll() async {
    final rows = await _db.chineseCharDao.getAll();
    return {for (final r in rows) r.char: _toEntity(r)};
  }

  Future<void> syncAll(List<ChineseChar> chars) async {
    final companions = chars.map((c) => ChineseCharsCompanion(
          char: Value(c.char),
          koreanChar: Value(c.koreanChar),
          soundReading: Value(jsonEncode(c.soundReading)),
          meanReading: Value(jsonEncode(c.meanReading)),
        ));
    await _db.chineseCharDao
        .upsertAll(companions.toList());
  }

  Future<bool> hasChars() => _db.chineseCharDao.hasChars();

  ChineseChar _toEntity(ChineseCharData row) => ChineseChar(
        char: row.char,
        koreanChar: row.koreanChar,
        soundReading: (jsonDecode(row.soundReading) as List).cast<String>(),
        meanReading: (jsonDecode(row.meanReading) as List).cast<String>(),
      );
}
