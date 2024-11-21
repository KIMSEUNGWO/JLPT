

import 'package:hive/hive.dart';

class VersionController {
  
  static const VersionController instance = VersionController();
  const VersionController();
  
  static const String VERSION_BOX = 'version_box';
  static const String CHINESE_CHAR_VERSION = 'chinese_char_version';
  static const String JAPAN_WORD_VERSION = 'japan_words_version';

  
  bool isChineseCharRequireUpdate(String version) {
    String? chineseCharVersion = _openVersion(CHINESE_CHAR_VERSION);
    print('dbVersion : $chineseCharVersion, afterVersion : $version');
    return chineseCharVersion != version;
  }
  bool isJapanWordsRequireUpdate(String version) {
    String? japanWordsVersion = _openVersion(JAPAN_WORD_VERSION);
    print('dbVersion : $japanWordsVersion, afterVersion : $version');
    return japanWordsVersion != version;
  }

  String? _openVersion(String boxKey) {
    return Hive.box(VERSION_BOX).get(boxKey);
  }
  void versionUpdate(String boxKey, String version) {
    var box = Hive.box(VERSION_BOX);
    box.put(boxKey, version);
  }
}