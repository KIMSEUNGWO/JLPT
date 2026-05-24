import 'dart:convert';

import 'package:jlpt_app/domain/course/course.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/study_group_size.dart';
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

  /// 코스 레벨별 회독 수. 키는 코스 네임스페이스(`cycle_<courseId>_<levelCode>`).
  /// 구버전(레벨 코드 단독) 키는 폴백으로 읽어 진행도를 보존한다.
  Map<Level, int> getStudyCycle(Course course) {
    return {
      for (final level in course.levels)
        level:
            _storage.getInt(_cycleKey(course.id, level.code)) ??
            _storage.getInt(level.code) ??
            0,
    };
  }

  Future<void> saveStudyCycle(Course course, Map<Level, int> data) async {
    for (final entry in data.entries) {
      await _storage.setInt(_cycleKey(course.id, entry.key.code), entry.value);
    }
  }

  String _cycleKey(String courseId, String levelCode) =>
      'cycle_${courseId}_$levelCode';

  // ───────── 학습한 단어 ID ─────────

  List<int> getReadWordIdList(Course course) {
    return _storage
            .getStringList(_readWordIdsKey(course.id))
            ?.map(int.parse)
            .toList() ??
        _storage
            .getStringList(StorageKey.READ_WORD_ID_LIST.name)
            ?.map(int.parse)
            .toList() ??
        const [];
  }

  Future<void> saveReadWordIdList(Course course, List<int> idList) async {
    await _storage.setStringList(
      _readWordIdsKey(course.id),
      idList.map((e) => e.toString()).toList(growable: false),
    );
  }

  String _readWordIdsKey(String courseId) =>
      '${StorageKey.READ_WORD_ID_LIST.name}_$courseId';

  // ───────── 최근 학습 ─────────

  ViewData getRecentlyViewData(Course course) {
    final levelStr = _storage.getString(StorageKey.RECENTLY_VIEW_LEVEL.name);
    final typeStr = _storage.getString(StorageKey.RECENTLY_VIEW_TYPE.name);
    final indexStr = _storage.getInt(StorageKey.RECENTLY_VIEW_INDEX.name);

    if (levelStr == null || typeStr == null || indexStr == null) {
      return ViewData();
    }
    final level = course.levelOrNull(levelStr);
    if (level == null) return ViewData();
    return ViewData.load(
      level: level,
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
      viewData.level!.code,
    );
    await _storage.setString(
      StorageKey.RECENTLY_VIEW_TYPE.name,
      viewData.type!.name,
    );
    await _storage.setInt(StorageKey.RECENTLY_VIEW_INDEX.name, viewData.index!);
  }

  // ───────── 레벨별 학습 타이머 ─────────

  /// 키는 코스 네임스페이스(`TIMER_<courseId>_<levelCode>`).
  /// 구버전(`TIMER_<levelCode>`) 키는 폴백으로 읽어 진행도를 보존한다.
  Map<Level, int> getTimerNotifier(Course course) {
    return {
      for (final level in course.levels)
        level:
            _storage.getInt(_timerKey(course.id, level.code)) ??
            _storage.getInt('${StorageKey.TIMER.name}_${level.code}') ??
            0,
    };
  }

  Future<void> saveTimerNotifier(Course course, Map<Level, int> data) async {
    for (final entry in data.entries) {
      await _storage.setInt(_timerKey(course.id, entry.key.code), entry.value);
    }
  }

  Future<void> saveLevelTimer(Course course, Level level, int seconds) async {
    await _storage.setInt(_timerKey(course.id, level.code), seconds);
  }

  String _timerKey(String courseId, String levelCode) =>
      '${StorageKey.TIMER.name}_${courseId}_$levelCode';

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

  // ───────── 학습 묶음 크기 ─────────

  int getStudyGroupSize() {
    final value =
        _storage.getInt(StorageKey.STUDY_GROUP_SIZE.name) ??
        defaultStudyGroupSize;
    return isAllowedStudyGroupSize(value) ? value : defaultStudyGroupSize;
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
  STUDY_GROUP_SIZE,
}
