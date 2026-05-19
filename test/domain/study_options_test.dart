import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/domain/study_options.dart';

void main() {
  group('StudyOptions', () {
    test('기본값은 모두 false', () {
      const opts = StudyOptions();
      expect(opts.autoPlayPronunciation, false);
      expect(opts.showHiragana, false);
      expect(opts.showKorean, false);
    });

    test('copyWith 으로 일부 필드만 변경', () {
      const opts = StudyOptions();
      final next = opts.copyWith(showHiragana: true);
      expect(next.showHiragana, true);
      expect(next.showKorean, false);
      expect(next.autoPlayPronunciation, false);
    });

    test('toJson/fromJson round-trip 보존', () {
      const opts = StudyOptions(
        autoPlayPronunciation: true,
        showHiragana: true,
        showKorean: false,
      );
      final restored = StudyOptions.fromJson(opts.toJson());
      expect(restored, opts);
    });

    test('누락 필드는 기본값(false) 으로 채움', () {
      final restored = StudyOptions.fromJson({'showHiragana': true});
      expect(restored.showHiragana, true);
      expect(restored.showKorean, false);
      expect(restored.autoPlayPronunciation, false);
    });

    test('타입이 다른 값은 FormatException', () {
      expect(
        () => StudyOptions.fromJson({'showHiragana': 'yes'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('== 와 hashCode 가 필드 기준 동치', () {
      const a = StudyOptions(showHiragana: true);
      const b = StudyOptions(showHiragana: true);
      const c = StudyOptions(showHiragana: false);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
