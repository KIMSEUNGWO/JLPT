
enum PracticeType {

  WORD(0),
  GRAMMAR(1)
  ;
  final int pageIndex;

  const PracticeType(this.pageIndex);

  static PracticeType valueOf(String json) {
    return switch (json) {
      'WORD' => PracticeType.WORD,
      'GRAMMAR' => PracticeType.GRAMMAR,
      String() => throw UnimplementedError(),
    };
  }

  static PracticeType valueOfIndex(int index) {
    return PracticeType.values.firstWhere((element) => element.pageIndex == index);
  }
}