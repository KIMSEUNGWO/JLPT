
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/level.dart';

class StudyCycleNotifier extends StateNotifier<Map<Level, int>> {

  StudyCycleNotifier() : super(Map.fromEntries(
    Level.values.map((level) => MapEntry(level, 0))
  ));

  init() {
    state = LocalStorage.instance.getStudyCycle();
  }

  _save() {
    LocalStorage.instance.saveStudyCycle(state);
  }

  int getCurrentCycle(Level level) {
    return state[level] ?? 0;
  }

  void cyclePlus(Level level) {
    state[level] = (state[level] ?? 0) + 1;

    state = { ...state };

    _save();
  }

}

final studyCycleNotifier = StateNotifierProvider<StudyCycleNotifier, Map<Level, int>>((ref) => StudyCycleNotifier());