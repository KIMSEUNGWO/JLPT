import 'dart:convert';

import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/study_options.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/notifier/entity/today.dart';
import 'package:jlpt_app/notifier/entity/view.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 싱글톤 래퍼.
///
/// 모든 mutation 메서드는 `Future<void>` 를 반환해서 호출 측에서 await 할 수 있도록 한다.
/// (구버전에서 fire-and-forget `setInt` 를 호출해 마지막 save 가 유실되던 버그 방지)
class LocalStorage {
  final SharedPreferences _storage;

  static late LocalStorage instance;
  LocalStorage._(this._storage);

  static Future<LocalStorage> initInstance() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    instance = LocalStorage._(sharedPreferences);
    return instance;
  }

  // ───────── 오늘의 학습 ─────────

  TodayData getTodayData() {
    final beforeDay = _storage.getInt(StorageKey.TODAY.name) ?? 0;
    if (beforeDay != dateToInt(DateTime.now())) {
      return TodayData.load(hours: 0, wordCnt: 0, grammarCnt: 0);
    }
    return TodayData.load(
      hours: _storage.getInt(StorageKey.TODAY_HOURS.name) ?? 0,
      wordCnt: _storage.getInt(StorageKey.TODAY_WORDS.name) ?? 0,
      grammarCnt: _storage.getInt(StorageKey.TODAY_GRAMMARS.name) ?? 0,
    );
  }

  Future<void> saveTodayData(TodayData data) async {
    await _storage.setInt(StorageKey.TODAY.name, data.date);
    await _storage.setInt(StorageKey.TODAY_HOURS.name, data.hours);
    await _storage.setInt(StorageKey.TODAY_WORDS.name, data.wordCnt);
    await _storage.setInt(StorageKey.TODAY_GRAMMARS.name, data.grammarCnt);
  }

  static int dateToInt(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  // ───────── 학습 회독 ─────────

  Map<Level, int> getStudyCycle() {
    return {
      for (final level in Level.values)
        level: _storage.getInt(level.name) ?? 0,
    };
  }

  Future<void> saveStudyCycle(Map<Level, int> data) async {
    for (final entry in data.entries) {
      await _storage.setInt(entry.key.name, entry.value);
    }
  }

  // ───────── 학습한 단어 ID ─────────

  List<int> getReadWordIdList() {
    return _storage
            .getStringList(StorageKey.READ_WORD_ID_LIST.name)
            ?.map(int.parse)
            .toList() ??
        const [];
  }

  Future<void> saveReadWordIdList(List<int> idList) async {
    await _storage.setStringList(
      StorageKey.READ_WORD_ID_LIST.name,
      idList.map((e) => e.toString()).toList(growable: false),
    );
  }

  // ───────── 최근 학습 ─────────

  ViewData getRecentlyViewData() {
    final levelStr = _storage.getString(StorageKey.RECENTLY_VIEW_LEVEL.name);
    final typeStr = _storage.getString(StorageKey.RECENTLY_VIEW_TYPE.name);
    final indexStr = _storage.getInt(StorageKey.RECENTLY_VIEW_INDEX.name);

    if (levelStr == null || typeStr == null || indexStr == null) {
      return ViewData();
    }
    return ViewData.load(
      level: Level.valueOf(levelStr),
      type: PracticeType.valueOf(typeStr),
      index: indexStr,
    );
  }

  Future<void> saveRecentlyViewData(ViewData viewData) async {
    if (viewData.level == null ||
        viewData.type == null ||
        viewData.index == null) {
      return;
    }
    await _storage.setString(
      StorageKey.RECENTLY_VIEW_LEVEL.name,
      viewData.level!.name,
    );
    await _storage.setString(
      StorageKey.RECENTLY_VIEW_TYPE.name,
      viewData.type!.name,
    );
    await _storage.setInt(
      StorageKey.RECENTLY_VIEW_INDEX.name,
      viewData.index!,
    );
  }

  // ───────── 레벨별 학습 타이머 ─────────

  Map<Level, int> getTimerNotifier() {
    return {
      for (final e in Level.values)
        e: _storage.getInt(_timerKey(e)) ?? 0,
    };
  }

  Future<void> saveTimerNotifier(Map<Level, int> data) async {
    for (final entry in data.entries) {
      await _storage.setInt(_timerKey(entry.key), entry.value);
    }
  }

  Future<void> saveLevelTimer(Level level, int seconds) async {
    await _storage.setInt(_timerKey(level), seconds);
  }

  String _timerKey(Level level) => '${StorageKey.TIMER.name}_${level.name}';

  // ───────── 학습 옵션 (자동 발음 / 히라가나 / 한국어) ─────────

  StudyOptions getStudyOptions() {
    final raw = _storage.getString(StorageKey.STUDY_OPTIONS.name);
    if (raw == null) return const StudyOptions();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const StudyOptions();
      return StudyOptions.fromJson(decoded);
    } catch (_) {
      // 손상된 JSON 이면 기본값으로 graceful — 사용자에게 옵션 초기화되도 앱은 동작.
      return const StudyOptions();
    }
  }

  Future<void> saveStudyOptions(StudyOptions options) async {
    await _storage.setString(
      StorageKey.STUDY_OPTIONS.name,
      jsonEncode(options.toJson()),
    );
  }
}

enum StorageKey {
  TODAY,
  TODAY_HOURS,
  TODAY_WORDS,
  TODAY_GRAMMARS,
  RECENTLY_VIEW_LEVEL,
  RECENTLY_VIEW_TYPE,
  RECENTLY_VIEW_INDEX,
  TIMER,
  READ_WORD_ID_LIST,
  STUDY_OPTIONS,
}
