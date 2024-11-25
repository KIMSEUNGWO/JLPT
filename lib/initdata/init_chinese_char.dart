
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/db/db_chinese_char_entity.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domaincontroller/chinese_char_controller.dart';
import 'package:jlpt_app/initdata/update/VersionInfo.dart';

class InitChineseCharHelper {


  init({VersionInfo? version}) async {
    if (version != null) {
      try {
        // var loadJson = await JsonReader.loadJson('chinese_chars');
        var loadJson = await JsonReader.loadJsonFromUrl('https://raw.githubusercontent.com/KIMSEUNGWO/JLPT/refs/heads/main/json/chinese_chars.json');

        var chineseCharEntity = ChineseCharEntity.fromJson(loadJson);

        await DBHive.instance.loadChineseChar(version, chineseCharEntity);
      } catch (e) {
        print('Chinese Char Internet Access Exception');
      }
    }
    ChineseCharController.instance.init();
  }
}