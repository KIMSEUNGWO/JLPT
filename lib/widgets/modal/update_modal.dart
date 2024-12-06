import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jlpt_app/component/chart/PieChart.dart';
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/component/snack_bar.dart';
import 'package:jlpt_app/domain/constant.dart';
import 'package:jlpt_app/initdata/update/VersionInfo.dart';

class UpdateModal extends StatefulWidget {

  final Function() updateComplete;

  const UpdateModal({
    super.key, required this.updateComplete,
  });

  @override
  State<UpdateModal> createState() => _UpdateModalState();
}

class _UpdateData {
  
  final String link;
  final String jsonFileName;

  _UpdateData({required this.link, required this.jsonFileName});
}

class _UpdateModalState extends State<UpdateModal> {

  late VersionInfo _version;
  late double fileSize;
  bool _isLoading = true;
  
  int updateIndex = 1;
  final List<_UpdateData> updateList = [
    _UpdateData(link: Constant.CHINESE_CHARS_LINK, jsonFileName: 'chinese_chars'),
    _UpdateData(link: Constant.JAPANESE_WORDS_LINK, jsonFileName: 'japanese_words'),
    _UpdateData(link: Constant.VERSION_LINK, jsonFileName: 'dataVersion'),
  ];

  bool _isDownloading = false;
  bool _isDownloadComplete = false;
  double _downloadedSize = 0.0;
  double _downloadedTotal = 0.1;

  // 다운로드 진행 상태 업데이트
  void _updateProgress(double progress, double total) {
    setState(() {
      _downloadedSize = progress;
      _downloadedTotal = total;
    });
  }

  // 다운로드 완료 후 처리
  void _onDownloadComplete() {
    setState(() {
      _isDownloading = false;
      _isDownloadComplete = true;
    });
    widget.updateComplete();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context);
      }
    },);
    // versionUpdate();
    // Navigator.pop(context); // 또는 성공 메시지 표시
  }

  // 파일 다운로드 함수
  Future<void> _downloadFiles() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadedSize = 0;
    });

    try {
      for (var data in updateList) {
        await JsonReader.downloadJsonFromUrl(data.link,
          jsonFileName: data.jsonFileName,
          onProgress: (current, total) {
            _updateProgress(current, total);
          },
        );
        setState(() {
          updateIndex++;
        });
      }
      _onDownloadComplete();
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      // 에러 처리
      if (mounted) {
        CustomSnackBar.instance.message(context, '다운로드 중 오류가 발생했습니다.');
      }
    }
  }


  // 파일 크기를 사람이 읽기 쉬운 형태로 변환
  String _formatFileSize(double bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  init() async {
    widget.updateComplete();
    var loadJson = await JsonReader.loadJsonFromUrl(Constant.VERSION_LINK);
    double versionSize = await JsonReader.getFileSize(Constant.VERSION_LINK);
    double chineseCharsSize = await JsonReader.getFileSize(Constant.CHINESE_CHARS_LINK);
    double japaneseWordsSize = await JsonReader.getFileSize(Constant.JAPANESE_WORDS_LINK);

    _version = VersionInfo.fromJson(loadJson);
    setState(() {
      fileSize = versionSize + chineseCharsSize + japaneseWordsSize;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CupertinoActivityIndicator(color: Colors.white,);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('데이터 업데이트 v${_version.version}',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.displayMedium!.fontSize,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 38),

              PieChart(
                radius: 60,
                strokeWidth: 14,
                totalSize: _downloadedTotal,
                currentSize: _downloadedSize,
                child: Center(
                  child: _isDownloading
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(_downloadedSize / _downloadedTotal * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${min(updateIndex, updateList.length)} / ${updateList.length}'),
                        ],
                    )
                    : _isDownloadComplete
                    ? _BonceIcon()
                    : IconButton(
                        onPressed: _downloadFiles,
                        icon: Icon(
                          Icons.file_download_outlined,
                          size: 50,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ),
                ),
              ),
              const SizedBox(height: 21),
              Column(
                children: [

                  Text(_version.description,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text('크기 : ${_formatFileSize(fileSize)}',
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
                  onPressed: () {
                    Navigator.pop(context);
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

class _BonceIcon extends StatefulWidget {
  const _BonceIcon();

  @override
  State<_BonceIcon> createState() => _BonceIconState();
}

class _BonceIconState extends State<_BonceIcon> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    );

    // 아이콘 바운스 애니메이션
    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);

    _controller.forward();

    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconAnimation.value,
          child: Icon(Icons.check_rounded,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}

