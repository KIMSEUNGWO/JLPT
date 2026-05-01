enum Level {
  N5,
  N4,
  N3,
  N2,
  N1;

  static Level valueOf(String json) => switch (json) {
        'N5' => Level.N5,
        'N4' => Level.N4,
        'N3' => Level.N3,
        'N2' => Level.N2,
        'N1' => Level.N1,
        _ => throw ArgumentError('Unknown Level: $json'),
      };
}
