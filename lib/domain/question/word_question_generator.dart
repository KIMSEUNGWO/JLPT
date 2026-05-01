import 'package:jlpt_app/domain/question_creator.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question/question_generator.dart';
import 'package:jlpt_app/domain/word.dart';

class WordQuestionGenerator extends QuestionGenerator<Word> {
  final Map<Level, List<Word>> _wordsByLevel;

  WordQuestionGenerator(this._wordsByLevel);

  @override
  List<Question> generateQuestions(Level? level, int count) {
    final allWords = _wordsByLevel.values.expand((e) => e).toList();
    final pool = level == null ? allWords : (_wordsByLevel[level] ?? []);
    final shuffled = shuffleAndCutCount(pool, count);
    return QuestionCreator.instance.createWordQuestions(
      totalWords: allWords,
      questionWords: shuffled,
    );
  }
}
