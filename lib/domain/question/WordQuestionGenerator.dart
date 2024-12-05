
import 'package:hive/hive.dart';
import 'package:jlpt_app/component/question_creator.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/box/japan_word_box.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question/QuestionGenerator.dart';
import 'package:jlpt_app/domain/word.dart';

class WordQuestionGenerator extends QuestionGenerator<Word> {

  @override
  List<Question> generateQuestions(Level? level, int count) {
    var box = _getJapanWordBox();

    var totalWords = box.values.expand((e) => e,).toList();
    var shuffle = shuffleAndCutCount(level == null ? totalWords : box[level]!, count);

    return QuestionCreator.instance.createWordQuestions(
      totalWords: totalWords,
      questionWords: shuffle,
    );
  }

  Map<Level, List<Word>> _getJapanWordBox() {
    var box = Hive.box(DBHive.JAPAN_WORDS_BOX);
    JapanWordBox? boxData = box.get('words');
    return boxData?.words ?? {};
  }

}