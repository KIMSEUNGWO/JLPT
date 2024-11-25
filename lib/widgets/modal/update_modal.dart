import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jlpt_app/component/chart/Data.dart';
import 'package:jlpt_app/component/chart/NPieChart.dart';
import 'package:jlpt_app/component/chart/NPieChart2.dart';
import 'package:jlpt_app/component/chart/PiePage.dart';
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/component/svg_icon.dart';
import 'package:jlpt_app/db/db_version_container.dart';
import 'package:jlpt_app/initdata/update/VersionInfo.dart';
import 'package:jlpt_app/widgets/component/record_component.dart';
import 'package:jlpt_app/widgets/component/record_row.dart';

class UpdateModal extends StatefulWidget {

  final VersionInfo version;

  const UpdateModal({
    super.key, required this.version,
  });

  @override
  State<UpdateModal> createState() => _UpdateModalState();
}

class _UpdateModalState extends State<UpdateModal> {

  versionUpdate() {
    // 버전 최신화
    VersionController.instance.versionUpdate(VersionController.VERSION, widget.version);
  }

  // 파일 크기를 사람이 읽기 쉬운 형태로 변환
  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  getFileSize() async {
    int? size = await JsonReader.getFileSize('https://raw.githubusercontent.com/KIMSEUNGWO/JLPT/refs/heads/main/json/chinese_chars.json');
    print('size : ${_formatFileSize(size!)}');
  }

  @override
  void initState() {
    getFileSize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('데이터 업데이트 v${widget.version.version}',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.displayMedium!.fontSize,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 38),

            Column(
              children: [

                Text(widget.version.description,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text('크기 : ',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F3F5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('다음에',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
