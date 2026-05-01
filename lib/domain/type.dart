enum PracticeType {
  WORD('단어'),
  GRAMMAR('문법');

  final String title;

  const PracticeType(this.title);

  static PracticeType valueOf(String json) => switch (json) {
        'WORD' => PracticeType.WORD,
        'GRAMMAR' => PracticeType.GRAMMAR,
        _ => throw ArgumentError('Unknown PracticeType: $json'),
      };
}
