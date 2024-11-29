
import 'package:flutter/material.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/initdata/update/UpdateChecker.dart';
import 'package:jlpt_app/notifier/recently_view_notifier.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/notifier/timer_notifier.dart';
import 'package:jlpt_app/notifier/today_notifier.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InitWidget extends ConsumerStatefulWidget {
  const InitWidget({super.key});

  @override
  createState() => _InitWidgetState();
}

class _InitWidgetState extends ConsumerState<InitWidget> {

  initNotifier() async {

    await LocalStorage.initInstance(); // 로컬 저장소 init

    ref.read(timerNotifier.notifier).init(); // 타이머 init
    ref.read(todayNotifier.notifier).init(); // 오늘의 학습 init
    ref.read(recentlyViewNotifier.notifier).init(); // 최근 공부한 기록 init
    ref.read(studyCycleNotifier.notifier).init(); // 레벨별 사이클 init

  }

  _adsInit() async {
    await MobileAds.instance.initialize();
  }

  @override
  void initState() {
    initNotifier();
    _adsInit();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const UpdateChecker();
  }
}
