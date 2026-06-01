import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question/word_question_generator.dart';
import 'package:jlpt_app/domain/study_level_kind.dart';
import 'package:jlpt_app/domain/word.dart';

const _n5 = Level(code: 'N5', label: 'N5', order: 0);
const _hiragana = Level(
  code: StudyLevelCodes.hiraganaChar,
  label: '문자',
  order: -4,
);

Word _word(int id, Level level) => Word(
  id: id,
  levelCode: level.code,
  act: Act.N,
  word: '단어$id',
  reading: 'reading$id',
  meaning: 'meaning$id',
  isRead: false,
  wrongCnt: 0,
  exampleIds: const [],
);

void main() {
  group('WordQuestionGenerator', () {
    test('통합 테스트는 kana 레벨을 출제 대상에서 제외한다', () {
      final questions = WordQuestionGenerator({
        _n5: [for (var i = 1; i <= 4; i++) _word(i, _n5)],
        _hiragana: [for (var i = 101; i <= 104; i++) _word(i, _hiragana)],
      }).generateQuestions(null, 10);

      expect(questions, hasLength(4));
      expect(
        questions
            .map((q) => q.question)
            .cast<Word>()
            .every((word) => word.levelCode == _n5.code),
        isTrue,
      );
    });

    test('kana 레벨 단독 테스트는 출제하지 않는다', () {
      final questions = WordQuestionGenerator({
        _n5: [for (var i = 1; i <= 4; i++) _word(i, _n5)],
        _hiragana: [for (var i = 101; i <= 104; i++) _word(i, _hiragana)],
      }).generateQuestions(_hiragana, 10);

      expect(questions, isEmpty);
    });
  });
}
