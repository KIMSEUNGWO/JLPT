import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/component/local_storage.dart';

void main() {
  group('LocalStorage', () {
    test('dateToInt은 날짜를 YYYYMMDD 정수로 변환한다', () {
      expect(LocalStorage.dateToInt(DateTime(2025, 4, 30)), 20250430);
      expect(LocalStorage.dateToInt(DateTime(2025, 1, 1)), 20250101);
      expect(LocalStorage.dateToInt(DateTime(2024, 12, 31)), 20241231);
    });
  });
}
