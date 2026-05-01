import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question/grammar_question_generator.dart';
import 'package:jlpt_app/domain/question/word_question_generator.dart';
import 'package:jlpt_app/domain/word.dart';

class TestExaminer {
  static final TestExaminer instance = TestExaminer._internal();
  TestExaminer._internal();

  List<Question> getWordQuestions({
    required Map<Level, List<Word>> wordsByLevel,
    Level? level,
    required int count,
  }) =>
      WordQuestionGenerator(wordsByLevel).generateQuestions(level, count);

  List<Question> getGrammarQuestions({Level? level, required int count}) =>
      GrammarQuestionGenerator().generateQuestions(level, count);
}
