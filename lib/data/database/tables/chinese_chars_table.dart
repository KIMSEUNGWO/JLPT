import 'package:drift/drift.dart';

@DataClassName('ChineseCharData')
class ChineseChars extends Table {
  TextColumn get char => text()();
  TextColumn get koreanChar => text()();
  TextColumn get soundReading => text()(); // JSON 인코딩된 List<String>
  TextColumn get meanReading => text()();  // JSON 인코딩된 List<String>

  @override
  Set<Column> get primaryKey => {char};
}
