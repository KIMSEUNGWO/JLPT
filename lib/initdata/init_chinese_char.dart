
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/db/db_chinese_char_entity.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domaincontroller/chinese_char_controller.dart';

class InitChineseCharHelper {


  init() async {
    try {
      // var loadJson = await JsonReader.loadJson('chinese_chars');
      var loadJson = await JsonReader.loadJsonFromUrl('https://raw.githubusercontent.com/KIMSEUNGWO/JLPT/refs/heads/main/assets/json/chinese_chars.json');

      var chineseCharEntity = ChineseCharEntity.fromJson(loadJson);

      await DBHive.instance.loadChineseChar(chineseCharEntity);
    } catch (e) {
      print('Chinese Char Internet Access Exception');
    }
    ChineseCharController.instance.init();
  }
}