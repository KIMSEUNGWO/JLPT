
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/word.dart';

/// 단어 목록에서 4지선다 Question 객체를 생성하는 순수 도메인 로직.
class QuestionCreator {
  static const QuestionCreator instance = QuestionCreator();
  const QuestionCreator();

  List<Question> createWordQuestions({
    required List<Word> totalWords,
    required List<Word> questionWords,
  }) {
    final actMap = <Act, List<Word>>{};
    for (final w in totalWords) {
      actMap.putIfAbsent(w.act, () => []).add(w);
    }
    return questionWords.map((word) => _buildQuestion(word, actMap)).toList();
  }

  Question _buildQuestion(Word word, Map<Act, List<Word>> actMap) {
    final distractors = _pickDistractors(word, actMap);
    return Question.create(
      question: word,
      examples: [word, ...distractors]..shuffle(),
    );
  }

  List<Word> _pickDistractors(Word word, Map<Act, List<Word>> actMap) {
    final candidates = Set<Word>.from(
      actMap[word.act]?.where((w) => w != word) ?? [],
    );

    if (candidates.length < 3) {
      final otherActs = Act.values.where((a) => a != word.act).toList()
        ..shuffle();
      for (final act in otherActs) {
        if (candidates.length >= 3) break;
        final pool = (actMap[act] ?? [])..shuffle();
        if (pool.isNotEmpty) candidates.add(pool.first);
      }
    }

    if (candidates.length < 3) {
      throw StateError('단어 부족: 4지선다를 만들 오답 후보가 3개 미만입니다.');
    }

    return (candidates.toList()..shuffle()).sublist(0, 3);
  }
}
