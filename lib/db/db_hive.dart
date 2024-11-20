

import 'package:hive/hive.dart';
import 'package:jlpt_app/db/db_chinese_char_entity.dart';
import 'package:jlpt_app/db/db_japanese_words_entity.dart';
import 'package:jlpt_app/db/db_version_container.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/domain/word_collection.dart';

class DBHive {

  static const DBHive instance = DBHive();
  const DBHive();

  static const String CHINESE_CHAR_BOX = 'chineseChar';
  static const String JAPAN_WORDS_BOX = 'japanWords';

  Future<List<ChineseChar>> loadChineseChar(ChineseCharEntity fromJson) async {
    await Hive.openBox(CHINESE_CHAR_BOX);
    Box box = Hive.box(CHINESE_CHAR_BOX);

    bool isRequireUpdate = await VersionController.instance.isChineseCharRequireUpdate(fromJson.version);

    // 업데이트가 필요없으면 Box에서 데이터를 바로 반환
    if (!isRequireUpdate) {
      print('Not Required ChineseChars');
      return box.values.map((e) => e as ChineseChar).toList();
    }

    // 업데이트 로직
    var values = {...box.values.map((e) => e as ChineseChar), ...fromJson.chars }.toList();
    await box.clear();
    await box.addAll(values);

    // 버전 최신화
    VersionController.instance.versionUpdate(VersionController.CHINESE_CHAR_VERSION, fromJson.version);

    return values;
  }

  Future<Map<Level, List<Word>>> loadJapanWords(JapanWordsEntity fromJson) async {
    await Hive.openBox(JAPAN_WORDS_BOX);
    Box box = Hive.box(JAPAN_WORDS_BOX);

    bool isRequireUpdate = await VersionController.instance.isJapanWordsRequireUpdate(fromJson.version);

    // box에서 데이터 가져오기
    JapanWordBox? boxData = box.get('words');

    Map<Level, List<Word>> dbState = boxData?.words ?? {};

    // 업데이트가 필요없으면 Box에서 데이터를 바로 반환
    if (!isRequireUpdate) {
      print('Not Required JapanWords');
      return dbState;
    }

    Map<Level, List<Word>> state = {};
    for (var e in fromJson.words) {
      state.putIfAbsent(e.level, () => [],).add(e);
    }

    // 결과를 저장할 Map
    Map<Level, List<Word>> mergedWords = {};

    for (Level level in Level.values) {
      mergedWords[level] = {...?dbState[level], ...?state[level]}.toList();
    }

    box.clear();
    // 새로운 JapanWordBox 객체 생성하여 저장
    box.put('words', JapanWordBox(words: mergedWords));

    // 버전 최신화
    VersionController.instance.versionUpdate(VersionController.JAPAN_WORD_VERSION, fromJson.version);

    return mergedWords;
  }
}

