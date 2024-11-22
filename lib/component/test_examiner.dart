

import 'dart:math';

import 'package:hive/hive.dart';
import 'package:jlpt_app/component/question_creator.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/box/japan_word_box.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/word.dart';

class TestExaminer {

  static const TestExaminer instance = TestExaminer();
  const TestExaminer();

  List<Question<Word>> getQuestions(Level level, int count) {
    var getJapanWordBox = _getJapanWordBox();

    var totalWords = getJapanWordBox.values.expand((e) => e,).toList();
    var shuffle = _shuffleAndCutCount(getJapanWordBox[level]!, count);

    return QuestionCreator.instance.createWordQuestions(
      totalWords: totalWords,
      questionWords: shuffle,
    );
  }

  List<Question<Word>> getAllQuestions(int count) {
    var getJapanWordBox = _getJapanWordBox();

    var totalWords = getJapanWordBox.values.expand((e) => e,).toList();
    var shuffle = _shuffleAndCutCount(totalWords, count);

    return QuestionCreator.instance.createWordQuestions(
      totalWords: totalWords,
      questionWords: shuffle,
    );
  }

  _shuffleAndCutCount(List<Word> words, int count) {
    words.shuffle();
    return words.sublist(0, min(words.length, count));
  }

  Map<Level, List<Word>> _getJapanWordBox() {
    var box = Hive.box(DBHive.JAPAN_WORDS_BOX);
    JapanWordBox? boxData = box.get('words');
    return boxData?.words ?? {};
  }
}