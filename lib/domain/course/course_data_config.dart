/// 코스 데이터의 출처(JSON 키)와 부팅 sync 검증 임계치. **immutable**.
class CourseDataConfig {
  const CourseDataConfig({
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
