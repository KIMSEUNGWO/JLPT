

import 'package:flutter_riverpod/src/consumer.dart';
import 'package:hive/hive.dart';
import 'package:jlpt_app/db/db_chinese_char_entity.dart';
import 'package:jlpt_app/db/db_japanese_words_entity.dart';
import 'package:jlpt_app/domain/box/chinese_char_box.dart';
import 'package:jlpt_app/domain/box/question_entity_box.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/domain/box/japan_word_box.dart';
import 'package:jlpt_app/initdata/update/VersionInfo.dart';
import 'package:jlpt_app/notifier/study_cycle_notifier.dart';

class DBHive {

  static const DBHive instance = DBHive();
  const DBHive();

  static const String CHINESE_CHAR_BOX = 'chineseChar';
  static const String JAPAN_WORDS_BOX = 'japanWords';
  static const String TEST_BOX = 'testBox';

  Future<void> loadChineseChar(ChineseCharEntity fromJson) async {
    Box box = Hive.box(CHINESE_CHAR_BOX);

    // box에서 데이터 가져오기
    ChineseCharBox? boxData = box.get('chars');

    Map<String, ChineseChar> dbState = boxData?.chars ?? {};


    // 업데이트 로직
    dbState.addAll({
      for (var char in fromJson.chars)
        char.char : char
    });

    await box.clear();
    // 새로운 JapanWordBox 객체 생성하여 저장
    await box.put('chars', ChineseCharBox(chars: dbState));

  }

  Future<void> loadJapanWords(JapanWordsEntity fromJson) async {
    Box box = Hive.box(JAPAN_WORDS_BOX);

    // box에서 데이터 가져오기
    JapanWordBox? boxData = box.get('words');

    Map<Level, List<Word>> dbState = boxData?.words ?? {};

    Map<Level, List<Word>> updateState = {};
    for (var e in fromJson.words) {
      updateState.putIfAbsent(e.level, () => [],).add(e);
    }


    for (Level level in Level.values) {
      List<Word?> list =  dbState[level]?.cast<Word?>() ?? [];
      for (Word newWord in updateState[level] ?? []) {
        Word? existingWord = list.firstWhere(
          (e) => e?.id == newWord.id,
          orElse: () => null
        );
        if (existingWord != null) {
          existingWord.word = newWord.word;
          existingWord.hiragana = newWord.hiragana;
          existingWord.korean = newWord.korean;
          existingWord.act = newWord.act;
        } else {
          // 새로운 단어는 리스트에 추가
          dbState.putIfAbsent(level, () => []).add(Word(
            id: newWord.id,
            level: newWord.level,
            act: newWord.act,
            word: newWord.word,
            hiragana: newWord.hiragana,
            korean: newWord.korean,
            isRead: false,    // 새 단어는 기본값으로 초기화
            wrongCnt: 0,      // 새 단어는 기본값으로 초기화
          ));
        }
      }
    }

    await box.clear();
    // 새로운 JapanWordBox 객체 생성하여 저장
    await box.put('words', JapanWordBox(words: dbState));

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

  updateWordIsReadTrue(Level level, Word word) async {
    Box box = Hive.box(JAPAN_WORDS_BOX);
    JapanWordBox? boxData = box.get('words');

    if (boxData == null) return;

    // 깊은 복사를 통해 새로운 Map 생성
    Map<Level, List<Word>> boxMap = Map.from(boxData.words);

    List<Word> list =  boxMap[level] ?? [];

    for (var o in list) {
      if (o.id == word.id) {
        o.isRead = true;
        break;
      }
    }

    await box.put('words', boxData);
  }


  Future<void> initialWords(WidgetRef ref, Level level) async {
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

  bool hasJapanWordsData() {
    Box box = Hive.box(JAPAN_WORDS_BOX);
    JapanWordBox? boxData = box.get('words');
    return boxData != null;
  }

  hasChineseCharsData() {
    Box box = Hive.box(CHINESE_CHAR_BOX);
    ChineseCharBox? boxData = box.get('chars');
    return boxData != null;
  }


  saveTestResult({Level? level, required PracticeType type, required List<Question> result, required int time, required List<bool> reverses}) async {
    Box box = Hive.box(TEST_BOX);

    for (var i = 0; i < result.length; ++i) {
      result[i].reverse = reverses[i];
      result[i].checkCorrect();
    }

    result.removeWhere((e) => e.myAnswer == null);

    int size = box.values.length;
    await box.add(QuestionEntityBox(
      id: size + 1,
      level: level,
      type: type,
      dateTime: DateTime.now(),
      question: result,
      time: time,
    ));
  }

  List<QuestionEntityBox> getTestResults() {
    Box box = Hive.box(TEST_BOX);
    return box.values.cast<QuestionEntityBox>().toList();
  }

}

