
import 'package:jlpt_app/domain/Act.dart';
import 'package:jlpt_app/domain/level.dart';

class Word {

  final int id;
  final Level level;
  final Act act;
  final String word;
  final String hiragana;
  final String korean;

  Word.fromJson(Map<String, dynamic> json):
    id = json['id'],
    level = Level.valueOf(json['level']),
    act = Act.valueOf(json['act']),
    word = json['word'],
    hiragana = json['hiragana'],
    korean = json['korean'];

}