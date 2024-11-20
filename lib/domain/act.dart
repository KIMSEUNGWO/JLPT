
import 'package:hive/hive.dart';

part 'act.g.dart';

@HiveType(typeId: 4)
enum Act{

  @HiveField(0)
  V,
  @HiveField(1)
  N,
  @HiveField(2)
  ADJ,
  @HiveField(3)
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