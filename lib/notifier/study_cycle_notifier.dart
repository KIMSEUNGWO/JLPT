import 'dart:async';

import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/course/course.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_cycle_notifier.g.dart';

@riverpod
class StudyCycleNotifier extends _$StudyCycleNotifier {
  Course get _course => ref.read(activeCourseProvider);

  @override
  Map<Level, int> build() => LocalStorage.instance.getStudyCycle(_course);

  void cyclePlus(Level level) {
    state = {...state, level: (state[level] ?? 0) + 1};
    unawaited(LocalStorage.instance.saveStudyCycle(_course, state));
  }

  int getCurrentCycle(Level level) => state[level] ?? 0;
}
