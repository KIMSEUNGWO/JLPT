

import 'package:hive_flutter/adapters.dart';
import 'package:jlpt_app/domain/chinese_char.dart';

part 'chinese_char_box.g.dart';

@HiveType(typeId: 6)
class ChineseCharBox extends HiveObject {

  @HiveField(0)
  final Map<String, ChineseChar> chars;

  ChineseCharBox({required this.chars});

}