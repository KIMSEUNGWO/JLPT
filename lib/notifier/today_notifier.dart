import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/notifier/entity/today.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_notifier.g.dart';

@riverpod
class TodayNotifier extends _$TodayNotifier {
  @override
  TodayData build() => LocalStorage.instance.getTodayData();

  void _save() {
    LocalStorage.instance.saveTodayData(state);
    state = TodayData.load(
      hours: state.hours,
      wordCnt: state.wordCnt,
      grammarCnt: state.grammarCnt,
    );
  }

  void plusHours(int time) {
    state.hours += time;
    _save();
  }

  void plusWordCnt() {
    state.wordCnt++;
    _save();
  }

  void plusGrammarCnt(int grammarCnt) {
    state.grammarCnt += grammarCnt;
    _save();
  }
}
