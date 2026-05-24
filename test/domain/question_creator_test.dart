import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/domain/question_creator.dart';
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/word.dart';

Word _makeWord(int id, Act act) => Word(
      id: id,
      levelCode: 'N5',
      act: act,
      word: '単語$id',
      reading: 'たんご$id',
      meaning: '단어$id',
      isRead: false,
      wrongCnt: 0,
      exampleIds: [100000 + id],
    );

void main() {
  group('QuestionCreator', () {
    test('4지선다 질문 생성', () {
      final total = [
        for (int i = 1; i <= 10; i++) _makeWord(i, Act.N),
        for (int i = 11; i <= 20; i++) _makeWord(i, Act.V),
      ];
      final questions = QuestionCreator.instance.createWordQuestions(
        totalWords: total,
        questionWords: total.sublist(0, 3),
      );

      expect(questions.length, 3);
      for (final q in questions) {
        expect(q.examples.length, 4, reason: '보기는 항상 4개');
        expect(q.examples.contains(q.question), isTrue, reason: '정답이 보기에 포함');
      }
    });

    test('동일 Act 단어를 우선 보기로 선택', () {
      final totalWords = [
        for (int i = 1; i <= 5; i++) _makeWord(i, Act.N),
        for (int i = 6; i <= 10; i++) _makeWord(i, Act.V),
      ];
      final questionWord = totalWords.first; // Act.N
      final questions = QuestionCreator.instance.createWordQuestions(
        totalWords: totalWords,
        questionWords: [questionWord],
      );

      final nounExamples =
          questions.first.examples.where((e) => (e as Word).act == Act.N).length;
      expect(nounExamples, greaterThanOrEqualTo(2),
          reason: '같은 품사 단어가 2개 이상 포함되어야 한다');
    });
  });
}
