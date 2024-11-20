import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/type.dart';
import 'package:jlpt_app/notifier/entity/today.dart';
import 'package:jlpt_app/notifier/entity/view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {

  final SharedPreferences _storage;

  static late LocalStorage instance;
  LocalStorage._(this._storage);

  static Future<LocalStorage> initInstance() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    instance = LocalStorage._(sharedPreferences);
    return instance;
  }

  TodayData getTodayData() {
    int beforeDay =_storage.getInt(StorageKey.TODAY.name) ?? 0;

    // 날짜가 달라지면 0으로 초기화
    if (beforeDay != dateToInt(DateTime.now())) {
      return TodayData.load(
        hours: 0,
        wordCnt: 0,
        grammarCnt: 0,
      );
    }
    int hours = _storage.getInt(StorageKey.TODAY_HOURS.name) ?? 0;
    int words = _storage.getInt(StorageKey.TODAY_WORDS.name) ?? 0;
    int grammars = _storage.getInt(StorageKey.TODAY_GRAMMARS.name) ?? 0;
    return TodayData.load(
      hours: hours,
      wordCnt: words,
      grammarCnt: grammars
    );
  }

  void saveTodayData(TodayData data) {
    _storage.setInt(StorageKey.TODAY.name, data.date);
    _storage.setInt(StorageKey.TODAY_HOURS.name, data.hours);
    _storage.setInt(StorageKey.TODAY_WORDS.name, data.wordCnt);
    _storage.setInt(StorageKey.TODAY_GRAMMARS.name, data.grammarCnt);
  }

  static int dateToInt(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  Map<Level, int> getStudyCycle() {
    return Map.fromEntries(Level.values.map((level) =>
        MapEntry(level, _storage.getInt(level.name) ?? 0))
    );
  }

  saveStudyCycle(Map<Level, int> data) {
    data.forEach((key, value) => _storage.setInt(key.name, value),);
  }

  List<int> getReadWordIdList() {
    return _storage.getStringList(StorageKey.READ_WORD_ID_LIST.name)?.map((e) => int.parse(e)).toList() ?? [];
  }
  saveReadWordIdList(List<int> idList) {
    var list = idList.map((e) => e.toString()).toList();
    _storage.setStringList(StorageKey.READ_WORD_ID_LIST.name, list);
  }

  ViewData getRecentlyViewData() {
    String? levelStr = _storage.getString(StorageKey.RECENTLY_VIEW_LEVEL.name);
    String? typeStr = _storage.getString(StorageKey.RECENTLY_VIEW_TYPE.name);
    int? indexStr = _storage.getInt(StorageKey.RECENTLY_VIEW_INDEX.name);

    if (levelStr == null || typeStr == null || indexStr == null) return ViewData();
    return ViewData.load(
      level: Level.valueOf(levelStr),
      type: PracticeType.valueOf(typeStr),
      index: indexStr
    );
  }

  void saveRecentlyViewData(ViewData viewData) {
    if (viewData.level == null || viewData.type == null || viewData.index == null) return;

    _storage.setString(StorageKey.RECENTLY_VIEW_LEVEL.name, viewData.level!.name);
    _storage.setString(StorageKey.RECENTLY_VIEW_TYPE.name, viewData.type!.name);
    _storage.setInt(StorageKey.RECENTLY_VIEW_INDEX.name, viewData.index!);
  }

  Map<Level, int> getTimerNotifier() {
    return { for (var e in Level.values) e : _storage.getInt(_timerCombineName(e)) ?? 0 };
  }

  saveTimerNotifier(Map<Level, int> data) {
    for (var o in data.entries) {
      _storage.setInt(_timerCombineName(o.key), o.value);
    }
  }
  void saveLevelTimer(Level level, int seconds) {
    _storage.setInt(_timerCombineName(level), seconds);
  }

  String _timerCombineName(Level level) {
    return '${StorageKey.TIMER.name}_${level.name}';
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

  READ_WORD_ID_LIST;

}