
import 'dart:math';

import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';

abstract class QuestionGenerator<T> {
  List<Question> generateQuestions(Level? level, int count);

  List<T> shuffleAndCutCount<T>(List<T> list, int count) {
    // List.from()을 사용한 깊은 복사
    final copiedList = List<T>.from(list);
    copiedList.shuffle();
    return copiedList.sublist(0, min(copiedList.length, count));
  }
}

