import 'package:drift/drift.dart';

@DataClassName('ChineseCharData')
class ChineseChars extends Table {
  /// 소속 코스 id (예: 'jlpt_ja'). 문자 모듈을 가진 코스만 row 를 채운다.
  TextColumn get course => text().withDefault(const Constant('jlpt_ja'))();
  TextColumn get char => text()();
  TextColumn get koreanChar => text()();
  TextColumn get soundReading => text()(); // JSON 인코딩된 List<String>
  TextColumn get meanReading => text()(); // JSON 인코딩된 List<String>

  @override
  Set<Column> get primaryKey => {course, char};
}
