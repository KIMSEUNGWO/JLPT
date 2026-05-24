import 'package:jlpt_app/data/sync/chinese_char_syncer.dart';
import 'package:jlpt_app/data/sync/example_sentence_syncer.dart';
import 'package:jlpt_app/data/sync/json_entity_syncer.dart';
import 'package:jlpt_app/data/sync/word_syncer.dart';
import 'package:jlpt_app/domain/course/course_data_config.dart';

/// Data 계층의 코스 동기화 구성.
///
/// UI 라벨이나 기능 표시 정보 없이, 데이터 키와 syncer 목록만 묶는다.
final class CourseSyncBundle {
  const CourseSyncBundle({
    required this.data,
    required this.wordSyncer,
    required this.charSyncer,
    required this.exampleSyncer,
  });

  final CourseDataConfig data;
  final WordSyncer wordSyncer;
  final ChineseCharSyncer? charSyncer;
  final ExampleSentenceSyncer exampleSyncer;

  List<JsonEntitySyncer<dynamic>> get syncers => [
    wordSyncer,
    ?charSyncer,
    exampleSyncer,
  ];
}
