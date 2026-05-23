import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/study_options.dart';
import 'package:jlpt_app/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Settings facade', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await LocalStorage.initInstance();
    });

    ProviderContainer makeContainer() {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      return c;
    }

    test('초기 상태는 LocalStorage 기본값', () {
      final c = makeContainer();

      expect(c.read(studyOptionsProvider), const StudyOptions());
      expect(c.read(studyGroupSizeProvider), 50);
      expect(c.read(settingsProvider).studyOptions, const StudyOptions());
      expect(c.read(settingsProvider).studyGroupSize, 50);
    });

    testWidgets('SettingsPage 토글로만 StudyOptions 변경 + LocalStorage 저장', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsPage())),
      );

      await tester.tap(find.text('히라가나 표시'));
      await tester.pump();
      await tester.pump();

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(StorageKey.STUDY_OPTIONS.name);
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['showHiragana'], true);
      expect(decoded['showKorean'], false);
      expect(decoded['autoPlayPronunciation'], false);
    });

    testWidgets('SettingsPage 토글들은 독립적으로 동작', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsPage()),
        ),
      );

      await tester.tap(find.text('자동 발음'));
      await tester.tap(find.text('한국어 뜻 표시'));
      await tester.pump();

      final state = container.read(studyOptionsProvider);
      expect(state.autoPlayPronunciation, true);
      expect(state.showKorean, true);
      expect(state.showHiragana, false);
    });

    testWidgets('같은 토글 두 번 호출 시 ON ↔ OFF', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsPage()),
        ),
      );

      await tester.tap(find.text('자동 발음'));
      await tester.pump();
      expect(container.read(studyOptionsProvider).autoPlayPronunciation, true);

      await tester.tap(find.text('자동 발음'));
      await tester.pump();
      expect(container.read(studyOptionsProvider).autoPlayPronunciation, false);
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
