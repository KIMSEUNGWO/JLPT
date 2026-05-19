import 'package:flutter/material.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/data/database/app_database.dart';

/// 오늘 포함 최근 7일의 학습량(초)을 막대로 표시.
///
/// fl_chart 등 외부 의존성 없이 `Container + Row` 만 사용 — 홈 화면이 가벼움.
/// 0 인 날도 baseline 회색 막대로 자리 채움 (학습 일관성 시각화).
class WeeklyBars extends StatelessWidget {
  const WeeklyBars({super.key, required this.data});

  /// 7개 row (오름차순, 오늘이 마지막).
  final List<DailyStatData> data;

  static const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  static const _maxBarHeight = 36.0;
  static const _minBarHeight = 2.0;

  @override
  Widget build(BuildContext context) {
    final today = LocalStorage.dateToInt(DateTime.now());
    final maxSeconds = data
        .map((d) => d.studySeconds)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _maxBarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < data.length; i++)
                Expanded(child: _bar(context, data[i], today, maxSeconds)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final d in data)
              Expanded(
                child: Text(
                  _weekdayLabels[_weekdayIndex(d.date)],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.bodySmall!.fontSize,
                    color: d.date == today
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        d.date == today ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _bar(
    BuildContext context,
    DailyStatData d,
    int today,
    int maxSeconds,
  ) {
    final isToday = d.date == today;
    final active = d.studySeconds > 0 || d.wordsLearned > 0;
    final ratio = maxSeconds == 0 ? 0.0 : d.studySeconds / maxSeconds;
    final height =
        active ? (_minBarHeight + ratio * (_maxBarHeight - _minBarHeight)) : _minBarHeight;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: !active
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : isToday
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  /// `YYYYMMDD` int → 요일 인덱스 (0=월).
  int _weekdayIndex(int dateInt) {
    final y = dateInt ~/ 10000;
    final m = (dateInt ~/ 100) % 100;
    final d = dateInt % 100;
    return DateTime(y, m, d).weekday - 1;
  }
}
