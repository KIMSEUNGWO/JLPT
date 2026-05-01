import 'package:jlpt_app/domain/grammar.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question/question_generator.dart';

class GrammarQuestionGenerator extends QuestionGenerator<Grammar> {
  @override
  List<Question> generateQuestions(Level? level, int count) {
    throw UnimplementedError('Grammar mode not yet released');
  }
}