import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/domain/study_options.dart';

void main() {
  group('StudyOptions', () {
    test('기본값은 모두 false', () {
      const opts = StudyOptions();
      expect(opts.autoPlayPronunciation, false);
      expect(opts.showReading, false);
      expect(opts.showMeaning, false);
    });

    test('copyWith 으로 일부 필드만 변경', () {
      const opts = StudyOptions();
      final next = opts.copyWith(showReading: true);
      expect(next.showReading, true);
      expect(next.showMeaning, false);
      expect(next.autoPlayPronunciation, false);
    });

    test('toJson/fromJson round-trip 보존', () {
      const opts = StudyOptions(
        autoPlayPronunciation: true,
        showReading: true,
        showMeaning: false,
      );
      final restored = StudyOptions.fromJson(opts.toJson());
      expect(restored, opts);
    });

    test('누락 필드는 기본값(false) 으로 채움', () {
      final restored = StudyOptions.fromJson({'showReading': true});
      expect(restored.showReading, true);
      expect(restored.showMeaning, false);
      expect(restored.autoPlayPronunciation, false);
    });

    test('구버전 키(showHiragana/showKorean)도 폴백으로 읽는다', () {
      final restored = StudyOptions.fromJson({
        'showHiragana': true,
        'showKorean': true,
      });
      expect(restored.showReading, true);
      expect(restored.showMeaning, true);
    });

    test('타입이 다른 값은 FormatException', () {
      expect(
        () => StudyOptions.fromJson({'showReading': 'yes'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('== 와 hashCode 가 필드 기준 동치', () {
      const a = StudyOptions(showReading: true);
      const b = StudyOptions(showReading: true);
      const c = StudyOptions(showReading: false);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
