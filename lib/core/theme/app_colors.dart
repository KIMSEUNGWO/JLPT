import 'package:flutter/material.dart';

/// 원시(raw) 색 팔레트.
///
/// 위젯 코드에서 직접 참조하지 말 것. 의미적인 접근은 다음 두 경로를 거친다:
///   - 표준 슬롯(브랜드/표면/텍스트/에러)은 `Theme.of(context).colorScheme` 또는 `context.colors`
///   - 보조 의미색(정/오답·그림자·tertiary 텍스트 등)은 `context.feedback`
///
/// 이 파일은 `AppTheme` 와 `AppFeedbackColors` 의 light 인스턴스에만 사용된다.
/// 차후 dark 추가 시 같은 형태로 `darkPalette` 를 추가하면 된다.
abstract class AppColors {
  // ── Light palette ────────────────────────────────────────────────────────
  // 배경
  static const Color background = Color(0xFFF1F3F5);
  static const Color card = Colors.white;
  static const Color surface = Color(0xFFF8F9FD);
  static const Color surfaceAlt = Color(0xFFF9FAFD);

  // 브랜드
  static const Color primary = Color(0xFF7373C9);
  static const Color primaryTint = Color(0xFFEAEAFF); // primary 10%
  static const Color onPrimary = Colors.white;

  // 텍스트
  static const Color textPrimary = Color(0xFF292929);
  static const Color textSecondary = Color(0xFF686868);
  static const Color textTertiary = Color(0xFF888888);

  // 시스템
  static const Color error = Color(0xFFFF5D5D);
  static const Color onError = Colors.white;

  // 테스트 결과 / 피드백
  static const Color correctText = Color(0xFF2E7D32);
  static const Color correctBackground = Color(0xFFE8F5E9);
  static const Color incorrectText = Color(0xFFC62828);
  static const Color incorrectBackground = Color(0xFFFFEBEE);

  // 구분선 / 기타
  static const Color divider = Color(0xFFE9ECEF);
  static const Color inactiveChart = Color(0xFFE1E1E1);
  static const Color snackBar = Color(0xFF414650);
  static const Color cardShadow = Color(0x0A000000); // black 4%

  // ── Dark palette (예약) ──────────────────────────────────────────────────
  // dark 추가 시 같은 키로 값만 정의해서 AppTheme.dark 에서 주입.
}
