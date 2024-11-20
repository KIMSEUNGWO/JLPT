import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/component/json/json_reader.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/constant.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word_extra.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';
import 'package:jlpt_app/notifier/today_notifier.dart';

class WordNotifier extends StateNotifier<Map<Level, List<WordExtra>>> {

  WordNotifier() : super({});

  init() async {
    var loadJson = await JsonReader.loadJson('japanese_words');
    var readWordIdList = LocalStorage.instance.getReadWordIdList();

    (loadJson['words'] as List).map((w) => WordExtra.fromJson(w))
        .forEach((word) {
      state.putIfAbsent(word.level, () => []).add(word);
      if (readWordIdList.contains(word.id)) word.isRead = true;
    });
  }

  List<WordExtra> getLevelWords(Level level) => state[level] ?? [];

  int getLevelSize(Level level) => state[level]?.length ?? 0;
  int getOnlyReadSize(Level level) {
    return state[level]?.where((word) => word.isRead).length ?? 0;
  }

  void read(WidgetRef ref, Level level, WordExtra wordExtra) {
    // 이미 이해하고 넘어간 단어는 리턴
    if (wordExtra.isRead) return;

    var firstWhere = state[level]?.firstWhere((element) => element.id == wordExtra.id);
    firstWhere?.isRead = true;
    state = {...state};

    ref.read(todayNotifier.notifier).plusWordCnt();
    // TODO 이해했음 버튼을 눌렀을때 저장소에 저장하게 해야됨 지금은 테스트 중이라 비활성화해놓음
    // var distinctList = {...LocalStorage.instance.getReadWordIdList(), wordExtra.id}.toList();
    // LocalStorage.instance.saveReadWordIdList(distinctList);
  }

  void initial(WidgetRef ref, Level level) {
    state[level]?.forEach((e) => e.isRead = false,);

    state = {...state};

    ref.read(studyCycleNotifier.notifier).cyclePlus(level);

    var readWordIdList = LocalStorage.instance.getReadWordIdList();
    readWordIdList.removeWhere((e) => state[level]?.any((element) => element.id == e,) ?? false);
    LocalStorage.instance.saveReadWordIdList(readWordIdList);
  }


}

final wordNotifier = StateNotifierProvider<WordNotifier, Map<Level, List<WordExtra>>>((ref) => WordNotifier());