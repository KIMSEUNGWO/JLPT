import 'package:jlpt_app/domain/course/course.dart';
import 'package:jlpt_app/domain/course/course_data_config.dart';
import 'package:jlpt_app/domain/level.dart';

const String _jlptBaseUrl =
    'https://raw.githubusercontent.com/KIMSEUNGWO/JLPT/refs/heads/main/assets/json';

/// JLPT 일본어 코스 — 현재 앱의 유일한 코스.
///
/// 새 코스(영어 CEFR·중국어 HSK 등)는 이 파일에 [Course] 를 하나 더 정의하고
/// [CourseRegistry.all] 에 등록 + 데이터 파일을 추가하면 된다.
const Course jlptJapaneseCourse = Course(
  identity: CourseIdentity(id: 'jlpt_ja'),
  presentation: CoursePresentation(
    displayName: 'JLPT',
    ttsLocale: 'ja-JP',
    termLanguageLabel: '일본어',
    readingLabel: '히라가나',
  ),
  capabilities: CourseCapabilities(
    hasCharacterModule: true,
    characterModuleLabel: '한자',
  ),
  levels: [
    Level(code: 'N5', label: 'N5', order: 0),
    Level(code: 'N4', label: 'N4', order: 1),
    Level(code: 'N3', label: 'N3', order: 2),
    Level(code: 'N2', label: 'N2', order: 3),
    Level(code: 'N1', label: 'N1', order: 4),
  ],
  data: CourseDataConfig(
    versionKey: 'dataVersion',
    wordsKey: 'japanese_words',
    charsKey: 'chinese_chars',
    examplesKey: 'example_sentences',
    remoteUrls: {
      'dataVersion': '$_jlptBaseUrl/dataVersion.json',
      'chinese_chars': '$_jlptBaseUrl/chinese_chars.json',
      'japanese_words': '$_jlptBaseUrl/japanese_words.json',
      'example_sentences': '$_jlptBaseUrl/example_sentences.json',
    },
    // N1~N5 합산 약 2200개. 안전마진 80%.
    minWordCount: 1800,
    // 번들 한자 약 1892개.
    minCharCount: 1500,
    // 전체 2150 단어 + default(id=0). 안전마진.
    minExampleCount: 2000,
  ),
);

/// 코드 레지스트리. 활성 코스 결정의 단일 지점.
///
/// 지금은 단일 코스라 [defaultCourse] 가 곧 활성 코스다. 추후 코스 선택 UI 가
/// 생기면 설정에서 읽은 id 로 [byId] 를 호출하도록 `activeCourseProvider` 만 바꾼다.
abstract final class CourseRegistry {
  static final List<Course> all = [jlptJapaneseCourse];

  static final Course defaultCourse = jlptJapaneseCourse;

  static Course byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => defaultCourse);
}
