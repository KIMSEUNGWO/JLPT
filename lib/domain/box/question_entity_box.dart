
import 'package:hive_flutter/adapters.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/type.dart';

part 'question_entity_box.g.dart';


@HiveType(typeId: 8)
class QuestionEntityBox extends HiveObject {

  @HiveField(0)
  final int id;
  @HiveField(1)
  final Level? level;
  @HiveField(2)
  final PracticeType type;
  @HiveField(3)
  final DateTime dateTime;
  @HiveField(4)
  final List<Question> question;
  @HiveField(5)
  final int time;

  QuestionEntityBox({required this.id, required this.level, required this.type, required this.dateTime, required this.question, required this.time});


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionEntityBox && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

}