import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_feedback_colors.dart';

/// 앱의 모든 `TextStyle` 토큰.
///
/// 슬롯 이름은 기존 코드가 의존하는 `headline*` / `display*` 매핑을 유지한다
/// (Material 의미상 display 가 더 큰 게 정석이지만, 위젯 코드 전면 교체를 피하기
/// 위해 보존). 새 자리(`titleLarge`/`titleMedium`/`labelLarge`)는 AppBar·섹션
/// 제목·버튼 용으로 추가됐다.
///
/// 모든 슬롯은 `height: 1.4` / 기본 색은 주입된 `ColorScheme` 과
/// `AppFeedbackColors` 에서 온다. 호출자는 `context.text.<slot>` 로 받고
/// 색이 다르면 `.copyWith(color: ...)` 한다.
abstract class AppTypography {
  static const double _height = 1.4;

  static TextTheme textTheme(
    ColorScheme colorScheme,
    AppFeedbackColors feedback,
  ) => TextTheme(
    // 가장 큰 단어 카드 글자.
    headlineLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
      height: _height,
    ),
    // 모달의 큰 제목, 점수 표시 등.
    headlineMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
      height: _height,
    ),
    // 큰 단어/한자 텍스트 (음독·훈독 등).
    displayLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
      height: _height,
    ),
    // 페이지 헤더, 모달 본문 강조 (예: "축하합니다!").
    displayMedium: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
      height: _height,
    ),
    // 섹션 제목, 카드 헤딩 (예: "단어 1-10", "JLPT N1").
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
      height: _height,
    ),
    // AppBar 제목 — 기존 _appBarTitle 대체.
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
      height: _height,
    ),
    // displaySmall 의 별칭 — Material 의미상 더 적합한 자리.
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
      height: _height,
    ),
    bodyLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurface,
      height: _height,
    ),
    bodyMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurfaceVariant,
      height: _height,
    ),
    bodySmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: feedback.textTertiary,
      height: _height,
    ),
    // 버튼 / 칩 텍스트.
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
      height: _height,
    ),
  );

  /// 점수·결과 강조용 보조 글꼴(Tmoney). `AppTextExtras.score` 로 노출되며
  /// `context.scoreText` 로 접근한다.
  static TextStyle score(ColorScheme colorScheme) => TextStyle(
    fontFamily: 'Tmoney',
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: colorScheme.onSurface,
    height: _height,
  );
}
