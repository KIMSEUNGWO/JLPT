import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/notifier/today_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_notifier.g.dart';

@riverpod
class TimerNotifier extends _$TimerNotifier {
  @override
  Map<Level, int> build() => LocalStorage.instance.getTimerNotifier();

  void setTimer(Level level, int seconds) {
    state = {...state, level: (state[level] ?? 0) + seconds};
    LocalStorage.instance.saveLevelTimer(level, state[level]!);
    ref.read(todayProvider.notifier).plusHours(seconds);
  }

  int getLevelTime(Level level) => state[level] ?? 0;
}
