import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalStorage', () {
    test('dateToInt은 날짜를 YYYYMMDD 정수로 변환한다', () {
      expect(LocalStorage.dateToInt(DateTime(2025, 4, 30)), 20250430);
      expect(LocalStorage.dateToInt(DateTime(2025, 1, 1)), 20250101);
      expect(LocalStorage.dateToInt(DateTime(2024, 12, 31)), 20241231);
    });

    test('study group size 기본값은 50', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final storage = await LocalStorage.initInstance();

      expect(storage.getStudyGroupSize(), 50);
    });

    test('study group size 저장 후 읽기', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final storage = await LocalStorage.initInstance();

      await storage.saveStudyGroupSize(20);

      expect(storage.getStudyGroupSize(), 20);
    });

    test('study group size 허용되지 않은 저장값은 50으로 fallback', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        StorageKey.STUDY_GROUP_SIZE.name: 15,
      });
      final storage = await LocalStorage.initInstance();

      expect(storage.getStudyGroupSize(), 50);
    });

    test('study group size 허용되지 않은 값 저장은 ArgumentError', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final storage = await LocalStorage.initInstance();

      await expectLater(storage.saveStudyGroupSize(15), throwsArgumentError);
    });
  });
}
