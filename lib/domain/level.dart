/// 한 [Course] 안의 학습 레벨. 코스마다 레벨 체계가 다르다
/// (예: JLPT N5~N1, HSK 1~6, CEFR A1~C2). **immutable**.
///
/// [code] 가 정체성이다 — DB·SharedPreferences·라우트 path 에 저장되는 값이며
/// [Map] 의 key 로 쓰이므로 동등성/해시는 code 기준이다. (코스 내 code 는 유일)
class Level {
  const Level({
    required this.code,
    required this.label,
    required this.order,
  });

  /// DB·스토리지·라우트에 저장되는 안정 식별자 (예: `'N5'`).
  final String code;

  /// UI 표시용 라벨 (예: `'N5'`, `'A1'`).
  final String label;

  /// 코스 내 정렬 순서 (작을수록 쉬움/먼저).
  final int order;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Level && other.code == code);

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Level($code)';
}
