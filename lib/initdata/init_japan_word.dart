
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/db/db_japanese_words_entity.dart';

class InitJapanWordHelper {


  init(bool isUpdated) async {
    // 혹시라도 데이터가 없으면 가져와야함
    var hasJapanWordsData = DBHive.instance.hasJapanWordsData();
    if (!isUpdated && hasJapanWordsData) return;

    try {
      var loadJson = await JsonReader.loadJson('japanese_words');
      var japanWordsEntity = JapanWordsEntity.fromJson(loadJson);

      await DBHive.instance.loadJapanWords(japanWordsEntity);
    } catch (e) {
      print('Japan Word Internet Access Exception');
      print(e);
    }
  }
}