import 'package:jlpt_app/domain/question_box.dart';

class Grammar implements QuestionBox {
  final String grammar;
  final String meaning;

  Grammar({required this.grammar, required this.meaning});

  @override
  String getTerm() => grammar;

  @override
  String getMeaning() => meaning;
}
