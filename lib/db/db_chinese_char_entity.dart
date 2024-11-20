

import 'package:jlpt_app/domain/chinese_char.dart';

class ChineseCharEntity {

  final String version;
  final List<ChineseChar> chars;

  ChineseCharEntity({required this.version, required this.chars});

  ChineseCharEntity.fromJson(Map<String, dynamic> json):
    version = json['version'],
    chars = List<ChineseChar>.from(json['chars'].map((char) => ChineseChar.fromJson(char)));
}