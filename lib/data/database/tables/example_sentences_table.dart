import 'package:drift/drift.dart';

/// 예문 본문. 여러 단어가 동일 예문을 참조할 수 있으므로 단어 row 와 분리.
@DataClassName('ExampleSentenceData')
class ExampleSentences extends Table {
  IntColumn get id => integer()();
  TextColumn get sentence => text()();
  TextColumn get translation => text()();

  @override
  Set<Column> get primaryKey => {id};
}
