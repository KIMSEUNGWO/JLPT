
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/domain/constant.dart';
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

  initData(bool isUpdated) async {
    await InitChineseCharHelper().init(isUpdated); // 한자 정보 로드
    await InitJapanWordHelper().init(isUpdated);
  }

  updateComplete() async {
    await initData(true);
  }

  showModal() {
    showDialog(
      context: context,
      builder: (context) {
        return UpdateModal(
          updateComplete: updateComplete,
        );
      },
    );
  }

  checkUpdates() async {
    bool isRequire = await isRequireUpdate();
    if (!isRequire) {
      await initData(false);
      return;
    }
    showModal();

  }

  Future<bool> isRequireUpdate() async {
    try {
      var loadJson = await JsonReader.loadJson('dataVersion');
      VersionInfo beforeVersion = VersionInfo.fromJson(loadJson);
      try {
        var internetVersion = await JsonReader.loadJsonFromUrl(Constant.VERSION_LINK);
        VersionInfo afterVersion = VersionInfo.fromJson(internetVersion);
        // 업데이트버전과 현재버전이 일치하지 않으면 업데이트가 필요함
        return beforeVersion.version != afterVersion.version;
      } catch (a) {
        // 인터넷 연결에 실패한 경우
        print('버전 체크 실패, 인터넷 연결에 실패함 : $a');
        return false;
      }
    } catch (e) {
      // 내부에 데이터가 존재하지 않는경우
      print('버전 체크 실패, 내부데이터가 존재하지 않음: $e');
      return true;
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
