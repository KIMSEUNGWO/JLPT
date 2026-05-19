/// 학습 카드의 표시·재생 옵션. **immutable** — 변경은 [copyWith] 로.
///
/// 카드 간 유지되는 영구 옵션이며 [LocalStorage] 의 JSON 으로 직렬화된다.
class StudyOptions {
  const StudyOptions({
    this.autoPlayPronunciation = false,
    this.showHiragana = false,
    this.showKorean = false,
  });

  final bool autoPlayPronunciation;
  final bool showHiragana;
  final bool showKorean;

  StudyOptions copyWith({
    bool? autoPlayPronunciation,
    bool? showHiragana,
    bool? showKorean,
  }) {
    return StudyOptions(
      autoPlayPronunciation:
          autoPlayPronunciation ?? this.autoPlayPronunciation,
      showHiragana: showHiragana ?? this.showHiragana,
      showKorean: showKorean ?? this.showKorean,
    );
  }

  Map<String, dynamic> toJson() => {
        'autoPlayPronunciation': autoPlayPronunciation,
        'showHiragana': showHiragana,
        'showKorean': showKorean,
      };

  /// 손상된 JSON 일 때 호출 측이 기본값으로 fallback 하기 쉽도록
  /// 누락 필드는 기본값(false) 으로 채운다. 타입 불일치는 throw.
  factory StudyOptions.fromJson(Map<String, dynamic> json) {
    return StudyOptions(
      autoPlayPronunciation: _bool(json, 'autoPlayPronunciation'),
      showHiragana: _bool(json, 'showHiragana'),
      showKorean: _bool(json, 'showKorean'),
    );
  }

  static bool _bool(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v == null) return false;
    if (v is bool) return v;
    throw FormatException("StudyOptions: '$key' must be bool (got $v)");
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyOptions &&
          other.autoPlayPronunciation == autoPlayPronunciation &&
          other.showHiragana == showHiragana &&
          other.showKorean == showKorean);

  @override
  int get hashCode =>
      Object.hash(autoPlayPronunciation, showHiragana, showKorean);

  @override
  String toString() =>
      'StudyOptions(autoPlay=$autoPlayPronunciation, hira=$showHiragana, kor=$showKorean)';
}
