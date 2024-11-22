
import 'package:jlpt_app/domain/question_box.dart';

class Question<T> {

  final QuestionBox<T> question;
  final List<QuestionBox<T>> examples;
  QuestionBox<T>? myAnswer;


  Question.create(
      {required this.question,
      required this.examples});

}