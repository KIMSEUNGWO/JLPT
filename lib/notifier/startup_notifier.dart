import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jlpt_app/component/app_logger.dart';
import 'package:jlpt_app/data/providers.dart';
import 'package:jlpt_app/data/sync/data_sync_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'startup_notifier.g.dart';

/// 앱 부팅 게이트.
///
/// `build()` 가 성공해야 메인 화면이 노출된다. 이걸 통해:
/// - 신규 사용자 시나리오에서 `wordsByLevelProvider` 가 빈 결과를 캐싱하는 경로 차단
/// - 부분 DB / 버전 불일치 시 자동 재동기화
/// - 데이터 sync 실패는 [SyncReportFailed] 로 표현되어 UI 에서 retry 가능
@riverpod
class Startup extends _$Startup {
  @override
  Future<SyncReport> build() async {
    // AdMob 초기화는 데이터 sync 와 무관하므로 fire-and-forget.
    // 실패해도 앱 부팅을 막지 않는다.
    unawaited(_initAds());

    final sync = ref.read(dataSyncServiceProvider);
    final report = await sync.ensureSynced();

    // sync 성공 시 파생 provider 무효화 — 빈 캐시를 절대 잡지 않도록.
    if (report.isOk) {
      ref.invalidate(wordsByLevelProvider);
      ref.invalidate(chineseCharCacheProvider);
    }

    return report;
  }

  Future<void> retry() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> _initAds() async {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      appLogger.w('[ads] init failed: $e');
    }
  }
}
