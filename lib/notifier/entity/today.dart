
import 'package:jlpt_app/component/local_storage.dart';

class TodayData {
  int hours;
  int wordCnt;
  int grammarCnt;
  final int date; // dateToInt 값 저장

  TodayData({
    this.hours = 0,
    this.wordCnt = 0,
    this.grammarCnt = 0,
    DateTime? date,
  }) : date = LocalStorage.dateToInt(date ?? DateTime.now());

  factory TodayData.load({required int hours, required int wordCnt, required int grammarCnt, DateTime? date,}) {
    return TodayData(
      hours: hours,
      wordCnt: wordCnt,
      grammarCnt: grammarCnt,
      date: date,
    );
  }

  static String formatTimeToHours(int seconds) {
    final hours = seconds / 3600; // 3600초 = 1시간
    if (hours < 0.1) return '0h';
    return '${hours.toStringAsFixed(1)}h';
  }
}
