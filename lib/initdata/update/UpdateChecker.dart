
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/db/db_version_container.dart';
import 'package:jlpt_app/initdata/init_chinese_char.dart';
import 'package:jlpt_app/initdata/init_japan_word.dart';
import 'package:jlpt_app/initdata/update/VersionInfo.dart';
import 'package:jlpt_app/widgets/modal/update_modal.dart';
import 'package:jlpt_app/widgets/page_main.dart';

class UpdateChecker extends StatefulWidget {
  const UpdateChecker({super.key});

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {

  double _progress = 0.8;
  String _fileSize = '';
  String _downloadedSize = '';

  initData() async {
    await InitChineseCharHelper().init(); // 한자 정보 로드
    await InitJapanWordHelper().init();
  }

  showModal(VersionInfo versionInfo) {
    showDialog(
      context: context,
      builder: (context) {
        return UpdateModal(
            version: versionInfo
        );
      },
    );
  }

  checkUpdates() async {
    var loadJson = await getVersion();
    if (loadJson == null) return;

    // VersionInfo versionInfo = VersionInfo.fromJson(loadJson);

    showModal(VersionInfo(version: '0.0.1', description: '오타수정', lastUpdated: DateTime.now()));
    // bool isRequireUpdate = VersionController.instance.isRequireUpdate(versionInfo);
    // if (isRequireUpdate) {
    //   showModal(versionInfo);
    // }
  }

  Future<Map<String, dynamic>?> getVersion() async {
    try {
      var loadJson = await JsonReader.loadJsonFromUrl('https://raw.githubusercontent.com/KIMSEUNGWO/JLPT/refs/heads/main/json/dataVersion.json');
      return loadJson;
    } catch (e) {
      print('버전 체크 실패: $e');
      return null;
    }
  }
  @override
  void initState() {
    checkUpdates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MainPage();
  }
}
