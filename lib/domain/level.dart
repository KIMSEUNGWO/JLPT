
import 'package:hive/hive.dart';

part 'level.g.dart';

@HiveType(typeId: 3)
enum Level {

  @HiveField(0)
  N5,
  @HiveField(1)
  N4,
  @HiveField(2)
  N3,
  @HiveField(3)
  N2,
  @HiveField(4)
  N1,
  ;

  static Level valueOf(String json) {
    return switch (json) {
      'N5' => Level.N5,
      'N4' => Level.N4,
      'N3' => Level.N3,
      'N2' => Level.N2,
      'N1' => Level.N1,
      String() => throw UnimplementedError(),
    };
  }

}