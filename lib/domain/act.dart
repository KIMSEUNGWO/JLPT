
enum Act{

  V,
  N,
  ADJ,
  ADV;

  static Act valueOf(String json) {
    return switch (json) {
      "V" => Act.V,
      "N" => Act.N,
      "ADJ" => Act.ADJ,
      "ADV" => Act.ADV,
      String() => throw UnimplementedError(json),
    };
  }
}