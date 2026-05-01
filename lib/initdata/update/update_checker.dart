import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/domain/constant.dart';
import 'package:jlpt_app/initdata/init_chinese_char.dart';
import 'package:jlpt_app/initdata/init_japan_word.dart';
import 'package:jlpt_app/initdata/update/version_info.dart';
import 'package:jlpt_app/widgets/modal/update_modal.dart';
import 'package:jlpt_app/widgets/page_main.dart';

class UpdateChecker extends ConsumerStatefulWidget {
  const UpdateChecker({super.key});

  @override
  ConsumerState<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends ConsumerState<UpdateChecker> {
  Future<void> _initData(bool isUpdated) async {
    final wordRepo = ref.read(wordRepositoryProvider);
    final charRepo = ref.read(chineseCharRepositoryProvider);
    await InitChineseCharHelper(charRepo).init(isUpdated);
    await InitJapanWordHelper(wordRepo).init(isUpdated);
  }

  void _showUpdateModal() {
    showDialog(
      context: context,
      builder: (_) => UpdateModal(
        updateComplete: () async {
          await _initData(true);
          // 다운로드 완료 후 홈 화면 단어 목록 강제 갱신
          ref.invalidate(wordsByLevelProvider);
        },
      ),
    );
  }

  Future<void> _checkUpdates() async {
    // DB가 비어있으면 번들 데이터를 먼저 로드 — 첫 설치 시 앱 즉시 사용 가능 보장
    await _initData(false);

    final needsUpdate = await _isUpdateRequired();
    if (!needsUpdate) {
      appLogger.d('이미 최신버전 입니다');
      return;
    }
    _showUpdateModal();
  }

  Future<bool> _isUpdateRequired() async {
    try {
      // 이미 다운로드된 버전 파일이 있으면 그것을 사용 (업데이트 이력 반영).
      // 없으면 번들 버전을 사용 — 번들은 앱 빌드 시점의 데이터를 나타냄.
      final localJson = await JsonReader.loadJson('dataVersion');
      final localVersion = VersionInfo.fromJson(localJson);

      final remoteJson =
          await JsonReader.loadJsonFromUrl(Constant.VERSION_LINK);
      final remoteVersion = VersionInfo.fromJson(remoteJson);
      return localVersion.version != remoteVersion.version;
    } on Exception catch (e) {
      // 인터넷 연결 실패 → 업데이트 여부 불확실, 현재 데이터로 진행
      appLogger.w('버전 체크 실패: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUpdates();
  }

  @override
  Widget build(BuildContext context) => const MainPage();
}
