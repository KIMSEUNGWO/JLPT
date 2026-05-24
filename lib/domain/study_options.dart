/// 학습 카드의 표시·재생 옵션. **immutable** — 변경은 [copyWith] 로.
///
/// 카드 간 유지되는 영구 옵션이며 [LocalStorage] 의 JSON 으로 직렬화된다.
class StudyOptions {
  const StudyOptions({
    this.autoPlayPronunciation = false,
    this.showReading = false,
    this.showMeaning = false,
  });

  final bool autoPlayPronunciation;

  /// 발음 표기(reading, 예: 히라가나) 를 카드에 먼저 보여줄지.
  final bool showReading;

  /// 사용자 언어 뜻을 카드에 먼저 보여줄지.
  final bool showMeaning;

  StudyOptions copyWith({
    bool? autoPlayPronunciation,
    bool? showReading,
    bool? showMeaning,
  }) {
    return StudyOptions(
      autoPlayPronunciation:
          autoPlayPronunciation ?? this.autoPlayPronunciation,
      showReading: showReading ?? this.showReading,
      showMeaning: showMeaning ?? this.showMeaning,
    );
  }

  Map<String, dynamic> toJson() => {
        'autoPlayPronunciation': autoPlayPronunciation,
        'showReading': showReading,
        'showMeaning': showMeaning,
      };

  /// 손상된 JSON 일 때 호출 측이 기본값으로 fallback 하기 쉽도록
  /// 누락 필드는 기본값(false) 으로 채운다. 타입 불일치는 throw.
  ///
  /// 하위호환: 구버전 키 `showHiragana`/`showKorean` 도 폴백으로 읽는다.
  factory StudyOptions.fromJson(Map<String, dynamic> json) {
    return StudyOptions(
      autoPlayPronunciation: _bool(json, 'autoPlayPronunciation'),
      showReading: _bool(json, 'showReading', legacyKey: 'showHiragana'),
      showMeaning: _bool(json, 'showMeaning', legacyKey: 'showKorean'),
    );
  }

  static bool _bool(Map<String, dynamic> json, String key, {String? legacyKey}) {
    final v = json[key] ?? (legacyKey != null ? json[legacyKey] : null);
    if (v == null) return false;
    if (v is bool) return v;
    throw FormatException("StudyOptions: '$key' must be bool (got $v)");
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyOptions &&
          other.autoPlayPronunciation == autoPlayPronunciation &&
          other.showReading == showReading &&
          other.showMeaning == showMeaning);

  @override
  int get hashCode =>
      Object.hash(autoPlayPronunciation, showReading, showMeaning);

  @override
  String toString() =>
      'StudyOptions(autoPlay=$autoPlayPronunciation, reading=$showReading, meaning=$showMeaning)';
}
