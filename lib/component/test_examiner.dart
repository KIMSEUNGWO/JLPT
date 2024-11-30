

import 'dart:math';

import 'package:hive/hive.dart';
import 'package:jlpt_app/component/question_creator.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/box/japan_word_box.dart';
import 'package:jlpt_app/domain/grammar.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question/GrammarQuestionGenerator.dart';
import 'package:jlpt_app/domain/question/QuestionGenerator.dart';
import 'package:jlpt_app/domain/question/WordQuestionGenerator.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';

class TestExaminer {

  static final TestExaminer instance = TestExaminer._internal();
  TestExaminer._internal();

  final Map<Type, QuestionGenerator> _generators = {
    Word: WordQuestionGenerator(),
    Grammar: GrammarQuestionGenerator(),
  };

  List<Question> getQuestions<T>({Level? level, required int count}) {
    final generator = _generators[T];
    if (generator == null) {
      throw UnimplementedError('No generator found for type: $T');
    }
    return (generator as QuestionGenerator<T>).generateQuestions(level, count);
  }

}