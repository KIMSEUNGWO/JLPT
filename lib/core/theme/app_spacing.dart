import 'package:flutter/material.dart';

import 'package:jlpt_app/core/theme/app_feedback_colors.dart';

/// 4pt 그리드 + T-shirt 사이즈. 모드(light/dark)에 무관한 토큰이므로 순수 const.
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// 라디우스 토큰. 가장 흔한 카드/모달 라디우스는 [md] (12).
abstract class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;

  /// 앱 전역 AppBar 하단 둥근 모서리.
  static const RoundedRectangleBorder appBarShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(lg),
      bottomRight: Radius.circular(lg),
    ),
  );
}

/// 그림자(elevation) 토큰. 색상은 현재 ThemeExtension 에서 받아 모드별 값을 따른다.
abstract class AppShadow {
  static List<BoxShadow> card(AppFeedbackColors feedback) => [
    BoxShadow(
      color: feedback.cardShadow,
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
  ];
}
