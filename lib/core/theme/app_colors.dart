import 'package:flutter/material.dart';

abstract class AppColors {
  // 배경
  static const Color background = Color(0xFFF1F3F5);
  static const Color surface = Color(0xFFF8F9FD);
  static const Color surfaceAlt = Color(0xFFF9FAFD);

  // 브랜드
  static const Color primary = Color(0xFF7373C9);
  static const Color primaryTint = Color(0xFFEAEAFF); // primary 10%

  // 텍스트
  static const Color textPrimary = Color(0xFF292929);
  static const Color textSecondary = Color(0xFF686868);
  static const Color textTertiary = Color(0xFF888888);

  // 시스템
  static const Color error = Color(0xFFFF5D5D);

  // 테스트 결과
  static const Color correctText = Color(0xFF2E7D32);
  static const Color correctBackground = Color(0xFFE8F5E9);
  static const Color incorrectText = Color(0xFFC62828);
  static const Color incorrectBackground = Color(0xFFFFEBEE);

  // 구분선 / 기타
  static const Color divider = Color(0xFFE9ECEF);
  static const Color inactiveChart = Color(0xFFE1E1E1);
  static const Color snackBar = Color(0xFF414650);
  static const Color cardShadow = Color(0x0A000000); // black 4%
}
