
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/db/db_japanese_words_entity.dart';
import 'package:jlpt_app/initdata/update/VersionInfo.dart';

class InitJapanWordHelper {


  init({VersionInfo? version}) async {
    if (version != null) {
      try {
        // var loadJson = await JsonReader.loadJson('japanese_words');
        var loadJson = await JsonReader.loadJsonFromUrl('https://raw.githubusercontent.com/KIMSEUNGWO/JLPT/refs/heads/main/json/japanese_words.json');

        var japanWordsEntity = JapanWordsEntity.fromJson(loadJson);

        await DBHive.instance.loadJapanWords(version, japanWordsEntity);
      } catch (e) {
        print('Japan Word Internet Access Exception');
      }
    }
  }
}