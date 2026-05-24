/// 정답/전체 → '90%' 형태로 변환. total == 0 이면 '0%'.
String correctRatePercent(int correct, int total) {
  if (total == 0) return '0%';
  return '${((correct / total) * 100).ceil().clamp(0, 100)}%';
}
