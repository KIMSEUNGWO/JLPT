import 'dart:async';

import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/study_options.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_options_notifier.g.dart';

/// 학습 카드의 노출/재생 옵션 (자동 발음, 히라가나, 한국어).
///
/// 앱 전역 단일 인스턴스로 공유되어야 하므로 [keepAlive] 사용.
/// 토글 후에는 LocalStorage 에 fire-and-forget 으로 저장한다.
@Riverpod(keepAlive: true)
class StudyOptionsNotifier extends _$StudyOptionsNotifier {
  @override
  StudyOptions build() => LocalStorage.instance.getStudyOptions();

  void toggleAutoPlay() {
    _update(state.copyWith(autoPlayPronunciation: !state.autoPlayPronunciation));
  }

  void toggleHiragana() {
    _update(state.copyWith(showHiragana: !state.showHiragana));
  }

  void toggleKorean() {
    _update(state.copyWith(showKorean: !state.showKorean));
  }

  void _update(StudyOptions next) {
    state = next;
    unawaited(LocalStorage.instance.saveStudyOptions(next));
  }
}
