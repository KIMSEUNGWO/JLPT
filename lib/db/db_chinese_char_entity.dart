

import 'package:jlpt_app/domain/chinese_char.dart';

class ChineseCharEntity {

  final List<ChineseChar> chars;

  ChineseCharEntity({required this.chars});

  ChineseCharEntity.fromJson(Map<String, dynamic> json):
    chars = List<ChineseChar>.from(json['chars'].map((char) => ChineseChar.fromJson(char)));
}