/// 예문. **immutable** — 변경이 필요하면 [copyWith] 를 사용.
///
/// 단어는 [id] 만 참조한다 (문장 자체를 중복 저장하지 않음).
class ExampleSentence {
  const ExampleSentence({
    required this.id,
    required this.sentence,
    required this.translation,
  });

  final int id;
  final String sentence;
  final String translation;

  /// 엄격한 JSON 파서. 누락/타입/빈 문자열 시 [FormatException].
  factory ExampleSentence.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) {
      throw FormatException("ExampleSentence: 'id' must be int (got $id)");
    }
    final sentence = json['sentence'];
    if (sentence is! String || sentence.isEmpty) {
      throw FormatException(
        "ExampleSentence(id=$id): 'sentence' must be non-empty String",
      );
    }
    final translation = json['translation'];
    if (translation is! String || translation.isEmpty) {
      throw FormatException(
        "ExampleSentence(id=$id): 'translation' must be non-empty String",
      );
    }
    return ExampleSentence(
      id: id,
      sentence: sentence,
      translation: translation,
    );
  }

  ExampleSentence copyWith({String? sentence, String? translation}) {
    return ExampleSentence(
      id: id,
      sentence: sentence ?? this.sentence,
      translation: translation ?? this.translation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExampleSentence && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ExampleSentence(id=$id)';
}