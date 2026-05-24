import 'package:jlpt_app/domain/level.dart';

/// 한 언어 학습 트랙("코스")의 정적 정의. **immutable**.
///
/// 단어 암기·플래시카드·테스트 기능 자체는 언어 중립적이며, 언어별 차이
/// (레벨 체계, TTS locale, reading 유무, 한자류 부가 모듈 등) 는 모두 이 객체로
/// 외부화한다. 새 언어를 추가하려면 [Course] 인스턴스 + 데이터 파일만 더하면 된다
/// (`course_registry.dart` 참고).
class Course {
  const Course({
    required this.id,
    required this.displayName,
    required this.ttsLocale,
    required this.termLanguageLabel,
    required this.readingLabel,
    required this.hasCharacterModule,
    required this.characterModuleLabel,
    required this.levels,
    required this.data,
  });

  /// DB `course` 컬럼·메타 키·스토리지 키에 쓰는 안정 식별자 (예: `'jlpt_ja'`).
  final String id;

  /// 레벨 앞에 붙는 표시 이름 (예: `'JLPT'` → "JLPT N5").
  final String displayName;

  /// TTS 발음 locale (예: `'ja-JP'`).
  final String ttsLocale;

  /// 학습 대상 언어의 사람이 읽는 이름 (예: `'일본어'`). 설정 문구 등에 사용.
  final String termLanguageLabel;

  /// 발음 표기(reading) 토글 라벨 (예: `'히라가나'`). `null` 이면 reading 없는 코스.
  final String? readingLabel;

  /// 한자/문자 분해 부가 모듈을 갖는지 (일본어 한자 = true).
  final bool hasCharacterModule;

  /// 문자 모듈 섹션 제목 (예: `'한자'`). 모듈 없으면 `null`.
  final String? characterModuleLabel;

  /// 정렬된 레벨 목록 (쉬움 → 어려움).
  final List<Level> levels;

  /// 데이터 소스(asset/remote 키 + 검증 임계치).
  final CourseDataSources data;

  bool get hasReading => readingLabel != null;

  Level? levelOrNull(String code) {
    for (final l in levels) {
      if (l.code == code) return l;
    }
    return null;
  }

  /// 코드로 레벨을 찾는다. 없으면 [ArgumentError].
  Level levelOf(String code) {
    final l = levelOrNull(code);
    if (l == null) {
      throw ArgumentError('Unknown level code "$code" in course $id');
    }
    return l;
  }
}

/// 코스 데이터의 출처(JSON 키)와 부팅 sync 검증 임계치. **immutable**.
class CourseDataSources {
  const CourseDataSources({
    required this.versionKey,
    required this.wordsKey,
    required this.charsKey,
    required this.examplesKey,
    required this.remoteUrls,
    required this.minWordCount,
    required this.minCharCount,
    required this.minExampleCount,
  });

  /// 데이터 버전 JSON 키 (보통 `'dataVersion'`).
  final String versionKey;

  /// 단어 JSON 키 (예: `'japanese_words'`).
  final String wordsKey;

  /// 문자(한자) JSON 키 (예: `'chinese_chars'`). 문자 모듈 없으면 `null`.
  final String? charsKey;

  /// 예문 JSON 키 (예: `'example_sentences'`).
  final String examplesKey;

  /// 위 key → 원격 URL 매핑 ([RemoteJsonDataSource] 에 주입).
  final Map<String, String> remoteUrls;

  /// 정상으로 간주할 최소 단어/문자/예문 row 수 (부분 DB 감지).
  final int minWordCount;
  final int minCharCount;
  final int minExampleCount;
}
