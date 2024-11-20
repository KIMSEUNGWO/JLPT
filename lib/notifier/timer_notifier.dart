

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/notifier/today_notifier.dart';

class TimerNotifier extends StateNotifier<Map<Level, int>> {

  TimerNotifier() : super({});

  init() {
    state = LocalStorage.instance.getTimerNotifier();
  }

  void setTimer(WidgetRef ref, Level level, int seconds) {
    state[level] = (state[level] ?? 0) + seconds;
    state = { ...state };

    LocalStorage.instance.saveLevelTimer(level, state[level]!);

    ref.read(todayNotifier.notifier).plusHours(seconds);
  }

  int getLevelTime(Level level) {
    return state[level] ?? 0;
  }


}

final timerNotifier = StateNotifierProvider<TimerNotifier, Map<Level, int>>((ref) => TimerNotifier());