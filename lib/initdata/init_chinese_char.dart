
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/domaincontroller/chinese_char_controller.dart';

class InitChineseCharHelper {


  init() async {
    var loadJson = await JsonReader.loadJson('chinese_chars');
    ChineseCharController.instance.putWord(loadJson);
  }
}