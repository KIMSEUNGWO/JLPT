import 'dart:async';

import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/course/course.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/notifier/today_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_notifier.g.dart';

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Course get _course => ref.read(activeCourseProvider);

  @override
  Map<Level, int> build() => LocalStorage.instance.getTimerNotifier(_course);

  void setTimer(Level level, int seconds) {
    state = {...state, level: (state[level] ?? 0) + seconds};
    unawaited(
        LocalStorage.instance.saveLevelTimer(_course, level, state[level]!));
    ref.read(todayProvider.notifier).plusHours(seconds);
  }

  int getLevelTime(Level level) => state[level] ?? 0;
}
