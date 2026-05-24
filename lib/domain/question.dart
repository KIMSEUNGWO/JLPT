import 'package:jlpt_app/domain/question_box.dart';

class Question {
  final QuestionBox question;
  final List<QuestionBox> examples;
  QuestionBox? myAnswer;
  bool reverse;
  bool isCorrect;

  Question({
    required this.question,
    required this.examples,
    this.myAnswer,
    this.reverse = false,
    this.isCorrect = false,
  });

  Question.create({required this.question, required this.examples})
      : reverse = false,
        isCorrect = false;

  void checkCorrect() {
    isCorrect = question.getTerm() == myAnswer?.getTerm();
  }
}
