import 'package:drift/drift.dart';

@DataClassName('TestResultData')
class TestResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get level => text().nullable()();
  TextColumn get type => text()();
  DateTimeColumn get takenAt => dateTime()();
  IntColumn get timeSeconds => integer()();
}
