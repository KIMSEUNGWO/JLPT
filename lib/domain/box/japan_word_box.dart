

import 'package:hive/hive.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';

part 'japan_word_box.g.dart';

@HiveType(typeId: 5)
class JapanWordBox extends HiveObject {

  @HiveField(0)
  final Map<Level, List<Word>> words;

  JapanWordBox({required this.words});

}