

class ChineseChar {

  final String char;

  final List<String> soundReading; // 음독
  final List<String> meanReading; // 훈독
  final String koreanChar;

  ChineseChar({required this.char, required this.soundReading, required this.meanReading, required this.koreanChar}); // 한국한

  ChineseChar.fromJson(Map<String, dynamic> json):
    char = json['char'],
    soundReading = json['soundReading'] == null ? [] : List<String>.from(json['soundReading'].map((x) => x.toString())),
    meanReading = json['meanReading'] == null ? [] : List<String>.from(json['meanReading'].map((x) => x.toString())),
    koreanChar = json['koreanChar'];
}