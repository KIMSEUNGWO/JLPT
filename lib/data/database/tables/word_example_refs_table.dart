import 'package:drift/drift.dart';
import 'package:jlpt_app/data/database/tables/example_sentences_table.dart';
import 'package:jlpt_app/data/database/tables/words_table.dart';

/// 단어-예문 다대다 참조 테이블.
///
/// 단어는 예문 문장 자체가 아니라 예문 id 만 참조한다.
/// `PRAGMA foreign_keys = ON` 환경에서 단어/예문이 사라지면 참조도 정리되도록
/// FK 를 명시 (`onDelete: CASCADE`).
@DataClassName('WordExampleRefData')
class WordExampleRefs extends Table {
  /// 소속 코스 id (예: 'jlpt_ja'). 다국어 코스 확장을 위한 차원.
  TextColumn get course => text().withDefault(const Constant('jlpt_ja'))();
  IntColumn get wordId => integer()
      .references(Words, #id, onDelete: KeyAction.cascade)();
  IntColumn get exampleId => integer()
      .references(ExampleSentences, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {wordId, exampleId};
}
