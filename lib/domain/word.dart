import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question_box.dart';

class Word implements QuestionBox {
  final int id;
  Level level;
  Act act;
  String word;
  String hiragana;
  String korean;
  bool isRead;
  int wrongCnt;

  Word({
    required this.id,
    required this.level,
    required this.act,
    required this.word,
    required this.hiragana,
    required this.korean,
    required this.isRead,
    required this.wrongCnt,
  });

  Word.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        level = Level.valueOf(json['level']),
        act = Act.valueOf(json['act']),
        word = json['word'],
        hiragana = json['hiragana'],
        korean = json['korean'],
        isRead = false,
        wrongCnt = 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Word && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'id: $id\nlevel: $level\nact: $act\nword: $word';

  @override
  String getJapanese() => word;

  @override
  String getKorean() => korean;
}
