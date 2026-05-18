/// 한자 정보. **immutable**.
class ChineseChar {
  const ChineseChar({
    required this.char,
    required this.koreanChar,
    required this.soundReading,
    required this.meanReading,
  });

  final String char;
  final String koreanChar;
  final List<String> soundReading; // 음독
  final List<String> meanReading;  // 훈독

  factory ChineseChar.fromJson(Map<String, dynamic> json) {
    final char = json['char'];
    if (char is! String || char.isEmpty) {
      throw const FormatException("ChineseChar: 'char' must be non-empty String");
    }
    final korean = json['koreanChar'];
    if (korean is! String) {
      throw FormatException(
        "ChineseChar(char=$char): 'koreanChar' must be String",
      );
    }
    return ChineseChar(
      char: char,
      koreanChar: korean,
      soundReading: _stringList(json['soundReading']),
      meanReading: _stringList(json['meanReading']),
    );
  }

  static List<String> _stringList(Object? v) {
    if (v == null) return const [];
    if (v is! List) {
      throw const FormatException('expected list of strings');
    }
    return v.map((e) => e.toString()).toList(growable: false);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ChineseChar && other.char == char);

  @override
  int get hashCode => char.hashCode;
}
