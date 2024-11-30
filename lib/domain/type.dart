
import 'package:hive/hive.dart';

part 'type.g.dart';

@HiveType(typeId: 9)
enum PracticeType {

  @HiveField(0)
  WORD(0, '단어'),
  @HiveField(1)
  GRAMMAR(1, '문법')
  ;


  final int pageIndex;
  final String title;

  const PracticeType(this.pageIndex, this.title);

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