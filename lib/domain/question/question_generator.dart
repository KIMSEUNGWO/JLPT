
import 'dart:math';

import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';

abstract class QuestionGenerator<T> {
  List<Question> generateQuestions(Level? level, int count);

  List<E> shuffleAndCutCount<E>(List<E> list, int count) {
    final copiedList = List<E>.from(list);
    copiedList.shuffle();
    return copiedList.sublist(0, min(copiedList.length, count));
  }
}

