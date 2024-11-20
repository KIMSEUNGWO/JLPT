
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/db/db_chinese_char_entity.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domaincontroller/chinese_char_controller.dart';

class InitChineseCharHelper {


  init() async {
    var loadJson = await JsonReader.loadJson('chinese_chars');

    var chineseCharEntity = ChineseCharEntity.fromJson(loadJson);

    List<ChineseChar> loadChineseChar = await DBHive.instance.loadChineseChar(chineseCharEntity);

    ChineseCharController.instance.putWord(loadChineseChar);
  }
}