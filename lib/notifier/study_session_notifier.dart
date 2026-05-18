import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/notifier/timer_notifier.dart';
import 'package:jlpt_app/notifier/today_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_notifier.g.dart';

/// 학습 세션의 부수효과 (시간 누적, 회독 증가, 읽음 초기화) 를 단일 진입점으로 모은다.
///
/// 라우팅 시 `Function`을 extra 로 전달하던 패턴을 제거하기 위한 notifier.
///
/// 화면 생명주기 중 안전한 시점에만 호출한다. dispose 콜백에서 provider 를
/// 호출하지 않도록 `CustomTimer` 와 `StudyPage` 가 책임을 분리한다.
@riverpod
class StudySession extends _$StudySession {
  @override
  void build() {}

  /// 학습 카드에서 누적된 초를 [level] 의 누적 학습시간에 더한다.
  void recordSeconds(Level level, int seconds) {
    if (seconds <= 0) return;
    ref.read(timerProvider.notifier).setTimer(level, seconds);
  }

  /// 단어를 "이해함" 으로 표시하고 오늘의 학습 단어 카운터 증가.
  Future<void> markWordRead(int wordId) async {
    await ref.read(wordRepositoryProvider).markRead(wordId);
    ref.read(todayProvider.notifier).plusWordCnt();
  }

  /// 한 cycle 완주 — 모든 isRead reset + cycle++.
  Future<void> completeCycle(Level level) async {
    await ref.read(wordRepositoryProvider).resetReadFor(level);
    ref.read(studyCycleProvider.notifier).cyclePlus(level);
    ref.invalidate(wordsByLevelProvider);
  }
}
