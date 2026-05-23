enum Act {
  V,
  N,
  ADJ,
  ADV,
  CONJ,
  EXP;

  static Act getRandomAct(Act? excludeAct) =>
      (Act.values.where((x) => x != excludeAct).toList()..shuffle()).first;

  static Act valueOf(String json) => switch (json) {
        'V' => Act.V,
        'N' => Act.N,
        'ADJ' => Act.ADJ,
        'ADV' => Act.ADV,
        'CONJ' => Act.CONJ,
        'EXP' => Act.EXP,
        _ => throw ArgumentError('Unknown Act: $json'),
      };
}
