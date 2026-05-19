import 'dart:async';

import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/notifier/entity/today.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_notifier.g.dart';

@riverpod
class TodayNotifier extends _$TodayNotifier {
  Future<void> _saveQueue = Future<void>.value();

  @override
  TodayData build() => LocalStorage.instance.getTodayData();

  void _queueSave(TodayData snapshot) {
    final save = _saveQueue
        .catchError((_) {
          // 이전 저장 실패가 다음 저장 순서를 막지 않게 한다.
        })
        .then((_) => LocalStorage.instance.saveTodayData(snapshot));

    _saveQueue = save;
    unawaited(
      save.catchError((Object e, StackTrace st) {
        appLogger.w('[today] save failed: $e\n$st');
      }),
    );
  }

  void plusHours(int time) {
    final next = TodayData.load(
      hours: state.hours + time,
      wordCnt: state.wordCnt,
      grammarCnt: state.grammarCnt,
    );
    state = next;
    _queueSave(next);
  }

  void plusWordCnt() {
    final next = TodayData.load(
      hours: state.hours,
      wordCnt: state.wordCnt + 1,
      grammarCnt: state.grammarCnt,
    );
    state = next;
    _queueSave(next);
  }

  void plusGrammarCnt(int grammarCnt) {
    final next = TodayData.load(
      hours: state.hours,
      wordCnt: state.wordCnt,
      grammarCnt: state.grammarCnt + grammarCnt,
    );
    state = next;
    _queueSave(next);
  }
}
