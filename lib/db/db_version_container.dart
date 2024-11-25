

import 'package:hive/hive.dart';
import 'package:jlpt_app/initdata/update/VersionInfo.dart';

class VersionController {
  
  static const VersionController instance = VersionController();
  const VersionController();
  
  static const String VERSION_BOX = 'version_box';
  static const String VERSION = 'version';


  bool isRequireUpdate(VersionInfo info) {
    String? version = _openVersion(VERSION);
    print('dbVersion : $version, afterVersion : ${info.version}');
    return version != info.version;
  }

  String? _openVersion(String boxKey) {
    return Hive.box(VERSION_BOX).get(boxKey);
  }
  void versionUpdate(String boxKey, VersionInfo version) {
    var box = Hive.box(VERSION_BOX);
    box.put(boxKey, version.version);
  }
}