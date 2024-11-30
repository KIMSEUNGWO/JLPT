

import 'package:jlpt_app/domain/question_box.dart';

class Grammar implements QuestionBox {

  final String grammar;
  final String korean;

  Grammar({required this.grammar, required this.korean});

  @override
  String getJapanese() {
    return grammar;
  }

  @override
  String getKorean() {
    return korean;
  }

}