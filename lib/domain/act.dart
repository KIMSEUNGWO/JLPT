enum Act {
  V,
  N,
  ADJ,
  ADV;

  static Act getRandomAct(Act? excludeAct) =>
      (Act.values.where((x) => x != excludeAct).toList()..shuffle()).first;

  static Act valueOf(String json) => switch (json) {
        'V' => Act.V,
        'N' => Act.N,
        'ADJ' => Act.ADJ,
        'ADV' => Act.ADV,
        _ => throw ArgumentError('Unknown Act: $json'),
      };
}
