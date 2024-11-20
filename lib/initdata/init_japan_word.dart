
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/db/db_japanese_words_entity.dart';

class InitJapanWordHelper {


  init() async {
    var loadJson = await JsonReader.loadJson('japanese_words');

    var japanWordsEntity = JapanWordsEntity.fromJson(loadJson);

    await DBHive.instance.loadJapanWords(japanWordsEntity);
  }
}