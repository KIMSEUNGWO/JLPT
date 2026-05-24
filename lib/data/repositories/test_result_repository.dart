import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/domain/box/question_entity_box.dart';
import 'package:jlpt_app/domain/course/course.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';

class TestResultRepository {
  final AppDatabase _db;
  final WordRepository _wordRepo;
  final Course _course;

  TestResultRepository(this._db, this._wordRepo, this._course);

  String get _courseId => _course.id;

  Future<QuestionEntityBox> save({
    Level? level,
    required PracticeType type,
    required List<Question> questions,
    required List<bool> reverses,
    required int time,
  }) async {
    for (var i = 0; i < questions.length; i++) {
      questions[i].reverse = reverses[i];
      questions[i].checkCorrect();
    }
    final answered = questions.where((q) => q.myAnswer != null).toList();

    return _db.transaction(() async {
      final now = DateTime.now();
      final resultId = await _db.testResultDao.insertResult(
        TestResultsCompanion(
          course: Value(_courseId),
          level: Value(level?.code),
          type: Value(type.name),
          takenAt: Value(now),
          timeSeconds: Value(time),
        ),
      );

      for (final q in answered) {
        final qWord = q.question as Word;
        final aWord = q.myAnswer as Word?;
        final exampleIds =
            q.examples.whereType<Word>().map((w) => w.id).toList();

        await _db.testResultDao.insertQuestion(
          TestQuestionsCompanion(
            testResultId: Value(resultId),
            questionWordId: Value(qWord.id),
            myAnswerWordId: Value(aWord?.id),
            isCorrect: Value(q.isCorrect),
            reverse: Value(q.reverse),
            examplesJson: Value(jsonEncode(exampleIds)),
          ),
        );
      }

      // 같은 transaction 안에서 일별 통계까지 누적 — 테스트 기록과 통계가
      // atomic 으로 정합. 한 쪽이 실패하면 다른 쪽도 rollback.
      final correctCount = answered.where((q) => q.isCorrect).length;
      await _db.dailyStatDao.increment(
        date: LocalStorage.dateToInt(now),
        testsTaken: 1,
        correct: correctCount,
        total: answered.length,
      );

      return QuestionEntityBox(
        id: resultId,
        level: level,
        type: type,
        dateTime: now,
        question: answered,
        time: time,
      );
    });
  }

  /// 배치 조회로 N+1 쿼리 방지: results + 모든 questions를 각 2번 쿼리로 해결.
  Future<List<QuestionEntityBox>> getAll() async {
    final results = await _db.testResultDao.getAllResults(_courseId);
    if (results.isEmpty) return [];

    // 모든 TestQuestion 행을 한 번에 가져옴
    final allQuestionRows = await _db.testResultDao.getAllQuestions();

    // 필요한 단어 ID를 한 번에 수집
    final wordIds = <int>{};
    for (final qr in allQuestionRows) {
      wordIds.add(qr.questionWordId);
      if (qr.myAnswerWordId != null) wordIds.add(qr.myAnswerWordId!);
      wordIds.addAll(WordRepository.decodeIds(qr.examplesJson));
    }
    final wordMap = {
      for (final w in await _wordRepo.getByIds(wordIds.toList())) w.id: w
    };

    // resultId 기준으로 questions 그룹핑
    final questionsByResult = <int, List<Question>>{};
    for (final qr in allQuestionRows) {
      final qWord = wordMap[qr.questionWordId];
      if (qWord == null) continue;

      final examples = WordRepository.decodeIds(qr.examplesJson)
          .map((id) => wordMap[id])
          .whereType<Word>()
          .toList();

      final q = Question.create(question: qWord, examples: examples);
      q.myAnswer = qr.myAnswerWordId != null ? wordMap[qr.myAnswerWordId!] : null;
      q.reverse = qr.reverse;
      q.isCorrect = qr.isCorrect;

      questionsByResult.putIfAbsent(qr.testResultId, () => []).add(q);
    }

    return results
        .map((r) => QuestionEntityBox(
              id: r.id,
              level: r.level != null ? _course.levelOrNull(r.level!) : null,
              type: PracticeType.valueOf(r.type),
              dateTime: r.takenAt,
              question: questionsByResult[r.id] ?? [],
              time: r.timeSeconds,
            ))
        .toList();
  }
}
