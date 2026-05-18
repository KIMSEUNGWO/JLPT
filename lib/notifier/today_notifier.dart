import 'dart:async';

import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/notifier/entity/today.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_notifier.g.dart';

@riverpod
class TodayNotifier extends _$TodayNotifier {
  @override
  TodayData build() => LocalStorage.instance.getTodayData();

  Future<void> _save() async {
    await LocalStorage.instance.saveTodayData(state);
    state = TodayData.load(
      hours: state.hours,
      wordCnt: state.wordCnt,
      grammarCnt: state.grammarCnt,
    );
  }

  void plusHours(int time) {
    state.hours += time;
    unawaited(_save());
  }

  void plusWordCnt() {
    state.wordCnt++;
    unawaited(_save());
  }

  void plusGrammarCnt(int grammarCnt) {
    state.grammarCnt += grammarCnt;
    unawaited(_save());
  }
}
