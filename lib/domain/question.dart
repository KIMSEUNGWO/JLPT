
import 'package:hive/hive.dart';
import 'package:jlpt_app/domain/question_box.dart';

part 'question.g.dart';

@HiveType(typeId: 7)
class Question extends HiveObject {

  @HiveField(0)
  final QuestionBox question;
  @HiveField(1)
  final List<QuestionBox> examples;
  @HiveField(2)
  QuestionBox? myAnswer;
  @HiveField(3)
  bool reverse = false;

  Question({required this.question, required this.examples, this.myAnswer, this.reverse = false});

  Question.create(
      {required this.question,
        required this.examples});

}