// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stat_dao.dart';

// ignore_for_file: type=lint
mixin _$DailyStatDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyStatsTable get dailyStats => attachedDatabase.dailyStats;
  DailyStatDaoManager get managers => DailyStatDaoManager(this);
}

class DailyStatDaoManager {
  final _$DailyStatDaoMixin _db;
  DailyStatDaoManager(this._db);
  $$DailyStatsTableTableManager get dailyStats =>
      $$DailyStatsTableTableManager(_db.attachedDatabase, _db.dailyStats);
}
