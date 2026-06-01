import 'package:jlpt_app/domain/question_creator.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question/question_generator.dart';
import 'package:jlpt_app/domain/study_level_kind.dart';
import 'package:jlpt_app/domain/word.dart';

class WordQuestionGenerator extends QuestionGenerator<Word> {
  final Map<Level, List<Word>> _wordsByLevel;

  WordQuestionGenerator(this._wordsByLevel);

  @override
  List<Question> generateQuestions(Level? level, int count) {
    final testableWordsByLevel = Map<Level, List<Word>>.fromEntries(
      _wordsByLevel.entries.where((entry) => entry.key.isJlpt),
    );
    final allWords = testableWordsByLevel.values.expand((e) => e).toList();
    final pool = level == null
        ? allWords
        : (level.isJlpt
              ? _wordsByLevel[level] ?? const <Word>[]
              : const <Word>[]);
    final shuffled = shuffleAndCutCount(pool, count);
    return QuestionCreator.instance.createWordQuestions(
      totalWords: allWords,
      questionWords: shuffled,
    );
  }
}
