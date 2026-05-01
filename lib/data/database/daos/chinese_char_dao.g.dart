// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chinese_char_dao.dart';

// ignore_for_file: type=lint
mixin _$ChineseCharDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChineseCharsTable get chineseChars => attachedDatabase.chineseChars;
  ChineseCharDaoManager get managers => ChineseCharDaoManager(this);
}

class ChineseCharDaoManager {
  final _$ChineseCharDaoMixin _db;
  ChineseCharDaoManager(this._db);
  $$ChineseCharsTableTableManager get chineseChars =>
      $$ChineseCharsTableTableManager(_db.attachedDatabase, _db.chineseChars);
}
