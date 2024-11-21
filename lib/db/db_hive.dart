

import 'package:flutter_riverpod/src/consumer.dart';
import 'package:hive/hive.dart';
import 'package:jlpt_app/db/db_chinese_char_entity.dart';
import 'package:jlpt_app/db/db_japanese_words_entity.dart';
import 'package:jlpt_app/db/db_version_container.dart';
import 'package:jlpt_app/domain/box/chinese_char_box.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/domain/box/japan_word_box.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';

class DBHive {

  static const DBHive instance = DBHive();
  const DBHive();

  static const String CHINESE_CHAR_BOX = 'chineseChar';
  static const String JAPAN_WORDS_BOX = 'japanWords';

  Future<void> loadChineseChar(ChineseCharEntity fromJson) async {
    Box box = Hive.box(CHINESE_CHAR_BOX);

    bool isRequireUpdate = await VersionController.instance.isChineseCharRequireUpdate(fromJson.version);

    // box에서 데이터 가져오기
    ChineseCharBox? boxData = box.get('chars');

    Map<String, ChineseChar> dbState = boxData?.chars ?? {};

    // 업데이트가 필요없으면 Box에서 데이터를 바로 반환
    if (!isRequireUpdate) {
      print('Not Required Update ChineseChars');
      return;
    }

    // 업데이트 로직
    dbState.addAll({
      for (var char in fromJson.chars)
        char.char : char
    });

    box.clear();
    // 새로운 JapanWordBox 객체 생성하여 저장
    box.put('chars', ChineseCharBox(chars: dbState));

    // 버전 최신화
    VersionController.instance.versionUpdate(VersionController.CHINESE_CHAR_VERSION, fromJson.version);

  }

  Future<void> loadJapanWords(JapanWordsEntity fromJson) async {
    Box box = Hive.box(JAPAN_WORDS_BOX);

    bool isRequireUpdate = await VersionController.instance.isJapanWordsRequireUpdate(fromJson.version);

    // box에서 데이터 가져오기
    JapanWordBox? boxData = box.get('words');

    Map<Level, List<Word>> dbState = boxData?.words ?? {};

    // 업데이트가 필요없으면 Box에서 데이터를 바로 반환
    if (!isRequireUpdate) {
      print('Not Required Update JapanWords');
      return;
    }

    Map<Level, List<Word>> state = {};
    for (var e in fromJson.words) {
      state.putIfAbsent(e.level, () => [],).add(e);
    }

    // 결과를 저장할 Map
    Map<Level, List<Word>> mergedWords = {};

    for (Level level in Level.values) {
      mergedWords[level] = { ...?state[level], ...?dbState[level] }.toList();
    }

    box.clear();
    // 새로운 JapanWordBox 객체 생성하여 저장
    box.put('words', JapanWordBox(words: mergedWords));

    // 버전 최신화
    VersionController.instance.versionUpdate(VersionController.JAPAN_WORD_VERSION, fromJson.version);
  }

  updateWordsIsReadTrue(List<int> wordIds) async {
    if (wordIds.isEmpty) return;

    Box box = Hive.box(JAPAN_WORDS_BOX);
    JapanWordBox? boxData = box.get('words');

    if (boxData == null) return;

    // 깊은 복사를 통해 새로운 Map 생성
    Map<Level, List<Word>> updatedWords = Map.from(boxData.words);

    for (var entry in updatedWords.entries) {
      var updatedList = entry.value.map((word) {
        if (!wordIds.contains(word.id)) return word;

        return Word(
          id: word.id,
          level: word.level,
          act: word.act,
          word: word.word,
          hiragana: word.hiragana,
          korean: word.korean,
          isRead: true,
          wrongCnt: word.wrongCnt
        );
      }).toList();

      updatedWords[entry.key] = updatedList;
    }
    // 저장
    await box.put('words', JapanWordBox(words: updatedWords));
  }

  void initialWords(WidgetRef ref, Level level) async {
    Box box = Hive.box(JAPAN_WORDS_BOX);
    JapanWordBox? boxData = box.get('words');

    if (boxData == null) return;

    // 깊은 복사를 통해 새로운 Map 생성
    Map<Level, List<Word>> updatedWords = Map.from(boxData.words);

    List<Word> updatedWord = updatedWords[level] ?? [];

    for (var e in updatedWord) {
      e.isRead = false;
    }

    updatedWords[level] = updatedWord;

    await box.put('words', JapanWordBox(words: updatedWords));

    ref.read(studyCycleNotifier.notifier).cyclePlus(level);
  }

  List<Word> getLevelWords(Level level) {
    Box box = Hive.box(JAPAN_WORDS_BOX);
    JapanWordBox? boxData = box.get('words');

    if (boxData == null) return [];

    // 깊은 복사를 통해 새로운 Map 생성
    return Map.from(boxData.words)[level] ?? [];
  }

  Map<String, ChineseChar> getChineseChars() {
    Box box = Hive.box(CHINESE_CHAR_BOX);
    ChineseCharBox? boxData = box.get('chars');
    return boxData?.chars ?? {};
  }
}

