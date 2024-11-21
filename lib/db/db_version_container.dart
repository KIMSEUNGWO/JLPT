

import 'package:hive/hive.dart';

class VersionController {
  
  static const VersionController instance = VersionController();
  const VersionController();
  
  static const String _VERSION_BOX = 'version_box';
  static const String CHINESE_CHAR_VERSION = 'chinese_char_version';
  static const String JAPAN_WORD_VERSION = 'japan_words_version';

  
  Future<bool> isChineseCharRequireUpdate(String version) async {
    String? chineseCharVersion = await _openVersion(CHINESE_CHAR_VERSION);
    print('dbVersion : $chineseCharVersion, afterVersion : $version');
    return chineseCharVersion != version;
  }
  Future<bool> isJapanWordsRequireUpdate(String version) async {
    String? japanWordsVersion = await _openVersion(JAPAN_WORD_VERSION);
    print('dbVersion : $japanWordsVersion, afterVersion : $version');
    return japanWordsVersion != version;
  }

  Future<String?> _openVersion(String boxKey) async {
    await Hive.openBox(_VERSION_BOX);
    return Hive.box(_VERSION_BOX).get(boxKey);
  }
  void versionUpdate(String boxKey, String version) async {
    Hive.openBox(_VERSION_BOX);
    var box = Hive.box(_VERSION_BOX);
    print(box.values);
    await box.put(boxKey, version);
  }
}