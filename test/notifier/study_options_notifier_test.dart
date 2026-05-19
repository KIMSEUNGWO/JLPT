import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/study_options.dart';
import 'package:jlpt_app/notifier/study_options_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StudyOptionsNotifier', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await LocalStorage.initInstance();
    });

    ProviderContainer makeContainer() {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      return c;
    }

    test('초기 상태는 LocalStorage 기본값 (모두 false)', () {
      final c = makeContainer();
      final state = c.read(studyOptionsProvider);
      expect(state, const StudyOptions());
    });

    test('toggleHiragana 후 state 변경 + LocalStorage 저장', () async {
      final c = makeContainer();
      c.read(studyOptionsProvider.notifier).toggleHiragana();

      expect(c.read(studyOptionsProvider).showHiragana, true);

      // fire-and-forget 저장 완료 대기
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(StorageKey.STUDY_OPTIONS.name);
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['showHiragana'], true);
      expect(decoded['showKorean'], false);
      expect(decoded['autoPlayPronunciation'], false);
    });

    test('세 토글 모두 독립적으로 동작', () {
      final c = makeContainer();
      final notifier = c.read(studyOptionsProvider.notifier);

      notifier.toggleAutoPlay();
      notifier.toggleKorean();
      // hiragana 는 OFF 유지

      final state = c.read(studyOptionsProvider);
      expect(state.autoPlayPronunciation, true);
      expect(state.showKorean, true);
      expect(state.showHiragana, false);
    });

    test('같은 토글 두 번 호출 시 ON ↔ OFF', () {
      final c = makeContainer();
      final notifier = c.read(studyOptionsProvider.notifier);

      notifier.toggleAutoPlay();
      expect(c.read(studyOptionsProvider).autoPlayPronunciation, true);
      notifier.toggleAutoPlay();
      expect(c.read(studyOptionsProvider).autoPlayPronunciation, false);
    });

    test('저장된 JSON 이 손상되어도 기본값으로 fallback', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        StorageKey.STUDY_OPTIONS.name: '{ invalid json',
      });
      await LocalStorage.initInstance();

      final c = makeContainer();
      expect(c.read(studyOptionsProvider), const StudyOptions());
    });
  });
}
