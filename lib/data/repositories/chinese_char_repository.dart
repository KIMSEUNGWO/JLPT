import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domain/course/course.dart';
import 'package:pub_semver/pub_semver.dart';

/// 문자(한자) 저장소. 활성 [Course] 에 스코프된다.
class ChineseCharRepository {
  final AppDatabase _db;
  final AppMetaRepository _meta;
  final Course _course;

  ChineseCharRepository(this._db, this._meta, this._course);

  String get _courseId => _course.id;

  Future<Map<String, ChineseChar>> getAll() async {
    final rows = await _db.chineseCharDao.getAll(_courseId);
    return {for (final r in rows) r.char: _toEntity(r)};
  }

  Future<void> syncAll(
    List<ChineseChar> chars, {
    required Version version,
  }) async {
    final companions = chars
        .map(
          (c) => ChineseCharsCompanion(
            course: Value(_courseId),
            char: Value(c.char),
            koreanChar: Value(c.koreanChar),
            soundReading: Value(jsonEncode(c.soundReading)),
            meanReading: Value(jsonEncode(c.meanReading)),
          ),
        )
        .toList(growable: false);

    await _db.transaction(() async {
      await _db.chineseCharDao.upsertAll(companions);
      await _meta.markCharsSynced(version, _courseId);
    });
  }

  Future<bool> hasChars() => _db.chineseCharDao.hasChars(_courseId);

  Future<int> countChars() => _db.chineseCharDao.countChars(_courseId);

  ChineseChar _toEntity(ChineseCharData row) => ChineseChar(
        char: row.char,
        koreanChar: row.koreanChar,
        soundReading: (jsonDecode(row.soundReading) as List).cast<String>(),
        meanReading: (jsonDecode(row.meanReading) as List).cast<String>(),
      );
}
