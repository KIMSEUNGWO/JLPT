
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/notifier/entity/today.dart';

class TodayNotifier extends StateNotifier<TodayData> {

  TodayNotifier() : super(TodayData());

  void init() {
    final savedData = LocalStorage.instance.getTodayData();

    // 날짜가 다르면 데이터 초기화
    if (dateToInt(DateTime.now()) != savedData.date) {
      state = TodayData(); // 새로운 날짜의 빈 데이터
    } else {
      state = savedData;
    }
  }

  // yyyyMMdd 형식으로 날짜를 정수 변환
  int dateToInt(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }
  _save() {
    LocalStorage.instance.saveTodayData(state);
    state = TodayData.load(hours: state.hours, wordCnt: state.wordCnt, grammarCnt: state.grammarCnt);
  }

  plusHours(int time) {
    state.hours += time;
    _save();
  }
  plusWordCnt() {
    state.wordCnt++;
    _save();
  }
  plusGrammarCnt(int grammarCnt) {
    state.grammarCnt += grammarCnt;
    _save();
  }




}

final todayNotifier = StateNotifierProvider<TodayNotifier, TodayData>((ref) => TodayNotifier());