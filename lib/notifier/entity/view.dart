
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';

class ViewData {

  Level? level;
  PracticeType? type;
  int? index;


  ViewData();

  ViewData.load({required this.level, required this.type, required this.index});
}