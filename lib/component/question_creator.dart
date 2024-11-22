
import 'dart:math';

import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/question_box.dart';
import 'package:jlpt_app/domain/word.dart';

class QuestionCreator {

  static const QuestionCreator instance = QuestionCreator();
  const QuestionCreator();


  List<Question<Word>> createWordQuestions({required List<Word> totalWords, required List<Word> questionWords}) {

    Map<Act, List<Word>> actMap = {};
    for (var e in totalWords) {
      actMap.putIfAbsent(e.act, () => [],).add(e);
    }

    return questionWords.map((word) => _select(word, actMap)).toList();
  }

  Question<Word> _select(Word word, Map<Act, List<Word>> actMap) {
    List<Word> actList = _getActWordList(word, actMap);
    var question = QuestionBox.wrap(word);
    return Question.create(
      question: question,
      examples: [ question , ...actList.map((x) => QuestionBox.wrap(x))]..shuffle(),
    );
  }

  List<Word> _getActWordList(Word word, Map<Act, List<Word>> actMap) {
    // 1. 같은 Act의 Word들을 먼저 수집하고 모두 사용
    Set<Word> resultWords = Set<Word>.from(
        actMap[word.act]?.where((w) => w != word).toList() ?? []
    );

    // 2. 다른 Act의 Word로 부족한 만큼 채우기
    if (resultWords.length < 3) {
      List<Act> otherActs = Act.values.where((a) => a != word.act).toList();

      while (resultWords.length < 3 && otherActs.isNotEmpty) {
        otherActs.shuffle();
        Act randomAct = otherActs.first;
        List<Word> otherActWords = actMap[randomAct] ?? [];

        if (otherActWords.isNotEmpty) {
          otherActWords.shuffle();
          resultWords.add(otherActWords.first);
        }

        otherActs.remove(randomAct);
      }
    }

    // 3. 최종 결과가 3개 미만이면 예외 처리
    if (resultWords.length < 3) {
      throw Exception('Not enough words available to create 3 examples');
    }

    // 4. 결과를 리스트로 변환하고 셔플한 후 정확히 3개만 반환
    var finalList = resultWords.toList()..shuffle();
    return finalList.sublist(0, 3);
  }

}