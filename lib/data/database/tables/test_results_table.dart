import 'package:drift/drift.dart';

@DataClassName('TestResultData')
class TestResults extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 소속 코스 id (예: 'jlpt_ja'). 다국어 코스 확장을 위한 차원.
  TextColumn get course => text().withDefault(const Constant('jlpt_ja'))();
  TextColumn get level => text().nullable()();
  TextColumn get type => text()();
  DateTimeColumn get takenAt => dateTime()();
  IntColumn get timeSeconds => integer()();
}
