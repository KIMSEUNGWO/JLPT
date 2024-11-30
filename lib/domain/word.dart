
import 'package:hive/hive.dart';
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question_box.dart';

part 'word.g.dart';

@HiveType(typeId: 2)
class Word extends HiveObject implements QuestionBox {

  @HiveField(0)
  final int id;
  @HiveField(1)
  Level level;
  @HiveField(2)
  Act act;
  @HiveField(3)
  String word;
  @HiveField(4)
  String hiragana;
  @HiveField(5)
  String korean;

  @HiveField(6)
  bool isRead = false;
  @HiveField(7)
  int wrongCnt = 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Word && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  Word({required this.id, required this.level, required this.act, required this.word, required this.hiragana, required this.korean, required this.isRead, required this.wrongCnt});

  Word.fromJson(Map<String, dynamic> json):
        id = json['id'],
        level = Level.valueOf(json['level']),
        act = Act.valueOf(json['act']),
        word = json['word'],
        hiragana = json['hiragana'],
        korean = json['korean'];

  @override
  String toString() {
    return 'id: $id\nlevel: $level\nact: $act\nword: $word';
  }

  @override
  String getJapanese() {
    return word;
  }

  @override
  String getKorean() {
    return korean;
  }

}