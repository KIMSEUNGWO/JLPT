
import 'package:flutter/material.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/initdata/init_chinese_char.dart';
import 'package:jlpt_app/notifier/recently_view_notifier.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/notifier/timer_notifier.dart';
import 'package:jlpt_app/notifier/today_notifier.dart';
import 'package:jlpt_app/notifier/word_notifier.dart';
import 'package:jlpt_app/widgets/page_main.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InitWidget extends ConsumerStatefulWidget {
  const InitWidget({super.key});

  @override
  createState() => _InitWidgetState();
}

class _InitWidgetState extends ConsumerState<InitWidget> {

  initNotifier() async {

    await LocalStorage.initInstance(); // 로컬 저장소 init
    await ref.read(wordNotifier.notifier).init(); // 일본어 단어 init, 읽음 로드

    ref.read(timerNotifier.notifier).init(); // 타이머 init
    ref.read(todayNotifier.notifier).init(); // 오늘의 학습 init
    ref.read(recentlyViewNotifier.notifier).init(); // 최근 공부한 기록 init
    ref.read(studyCycleNotifier.notifier).init(); // 레벨별 사이클 init

  }
  initData() {
    InitChineseCharHelper().init(); // 한자 정보 로드
  }

  initHive() async {


  }

  @override
  void initState() {
    initNotifier();
    initData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const MainPage();
  }
}
