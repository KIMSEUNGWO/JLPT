import 'package:drift/drift.dart';

@DataClassName('WordData')
class Words extends Table {
  IntColumn get id => integer()();
  TextColumn get level => text()();
  TextColumn get act => text()();
  TextColumn get word => text()();
  TextColumn get hiragana => text()();
  TextColumn get korean => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  IntColumn get wrongCnt => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
