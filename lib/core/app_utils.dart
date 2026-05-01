import 'package:flutter/material.dart';

/// 정답/전체 → '90%' 형태로 변환. total == 0 이면 '0%'.
String correctRatePercent(int correct, int total) {
  if (total == 0) return '0%';
  return '${((correct / total) * 100).ceil().clamp(0, 100)}%';
}

/// 앱 전역 AppBar 하단 둥근 모서리 Shape.
const kAppBarShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(14),
    bottomRight: Radius.circular(14),
  ),
);
