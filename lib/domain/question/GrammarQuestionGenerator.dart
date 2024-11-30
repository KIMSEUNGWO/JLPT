
import 'package:jlpt_app/domain/grammar.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question/QuestionGenerator.dart';

class GrammarQuestionGenerator extends QuestionGenerator<Grammar> {

  @override
  List<Question> generateQuestions(Level? level, int count) {
    var box = _getJapanGrammarBox();

    var totalWords = box.values.expand((e) => e,).toList();
    var shuffle = shuffleAndCutCount(level == null ? totalWords : box[level]!, count);

    // TODO: implement generateQuestions
    throw UnimplementedError();
  }

  Map<Level, List<Grammar>> _getJapanGrammarBox() {
    // var box = Hive.box(DBHive.JAPAN_WORDS_BOX);
    // JapanWordBox? boxData = box.get('words');
    // return boxData?.words ?? {};
    return {};
  }

}