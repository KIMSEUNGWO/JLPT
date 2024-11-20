

import 'package:hive/hive.dart';

part 'chinese_char.g.dart';  // 이 줄이 반드시 필요합니다!

@HiveType(typeId: 1)
class ChineseChar extends HiveObject {

  @HiveField(0)
  final String char;
  @HiveField(1)
  final List<String> soundReading; // 음독
  @HiveField(2)
  final List<String> meanReading; // 훈독
  @HiveField(3)
  final String koreanChar;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChineseChar && other.char == char;
  }

  @override
  int get hashCode => char.hashCode;

  ChineseChar({required this.char, required this.soundReading, required this.meanReading, required this.koreanChar});

  ChineseChar.fromJson(Map<String, dynamic> json):
    char = json['char'],
    soundReading = json['soundReading'] == null ? [] : List<String>.from(json['soundReading'].map((x) => x.toString())),
    meanReading = json['meanReading'] == null ? [] : List<String>.from(json['meanReading'].map((x) => x.toString())),
    koreanChar = json['koreanChar'];
}