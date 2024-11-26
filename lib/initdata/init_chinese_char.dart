
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/db/db_chinese_char_entity.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domaincontroller/chinese_char_controller.dart';

class InitChineseCharHelper {


  init(bool isUpdated) async {
    var hasChineseCharsData = DBHive.instance.hasChineseCharsData();

    if (isUpdated || !hasChineseCharsData) {
      try {
        var loadJson = await JsonReader.loadJson('chinese_chars');

        var chineseCharEntity = ChineseCharEntity.fromJson(loadJson);

        await DBHive.instance.loadChineseChar(chineseCharEntity);
      } catch (e) {
        print('Chinese Char Internet Access Exception');
      }
    }
    ChineseCharController.instance.init();
  }
}