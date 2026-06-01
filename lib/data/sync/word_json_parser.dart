import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/word.dart';

List<Word> parseWordsJson(Map<String, dynamic> json) {
  final rawWords = json['words'];
  if (rawWords is! Map) {
    throw const FormatException("words: 'words' must be an object grouped by level");
  }
  return _parseGroupedWords(rawWords);
}

List<Word> _parseGroupedWords(Map<dynamic, dynamic> grouped) {
  final result = <Word>[];
  for (final entry in grouped.entries) {
    final level = entry.key;
    if (level is! String || level.isEmpty) {
      throw FormatException("words: level key must be non-empty String (got $level)");
    }
    final rows = entry.value;
    if (rows is! List) {
      throw FormatException("words.$level must be an array");
    }
    result.addAll(_parseWordList(rows, 'words.$level', level: level));
  }
  return result;
}

List<Word> _parseWordList(List<dynamic> rows, String path, {required String level}) {
  final result = <Word>[];
  for (var i = 0; i < rows.length; i++) {
    final raw = rows[i];
    if (raw is! Map<String, dynamic>) {
      throw FormatException('$path[$i] is not a JSON object');
    }
    final json = _withGroupedLevel(raw, level, '$path[$i]');
    result.add(Word.fromJson(json));
  }
  return result;
}

Map<String, dynamic> _withGroupedLevel(
  Map<String, dynamic> raw,
  String level,
  String path,
) {
  final existing = raw['level'];
  if (existing != null && existing != level) {
    throw FormatException(
      "$path level '$existing' does not match grouped level '$level'",
    );
  }
  return {...raw, 'level': level};
}

/// 카나(히라가나/가타카나) 학습용 간이 단어 파서.
///
/// 카나 단어는 품사(act)·발음(reading)·예문(exampleIds)이 의미가 없으므로
/// JSON 은 `{id, word, meaning}` 만 담는다. 나머지는 기본값으로 채운다.
/// 메인 단어 데이터의 엄격한 [parseWordsJson] 검증과 분리해 둔다.
List<Word> parseKanaWordsJson(Map<String, dynamic> json) {
  final rawWords = json['words'];
  if (rawWords is! Map) {
    throw const FormatException(
      "kana words: 'words' must be an object grouped by level",
    );
  }
  final result = <Word>[];
  for (final entry in rawWords.entries) {
    final level = entry.key;
    if (level is! String || level.isEmpty) {
      throw FormatException("kana words: level key must be non-empty String (got $level)");
    }
    final rows = entry.value;
    if (rows is! List) {
      throw FormatException("kana words.$level must be an array");
    }
    for (var i = 0; i < rows.length; i++) {
      final raw = rows[i];
      if (raw is! Map<String, dynamic>) {
        throw FormatException('kana words.$level[$i] is not a JSON object');
      }
      final id = raw['id'];
      if (id is! int) {
        throw FormatException("kana words.$level[$i]: 'id' must be int");
      }
      final word = raw['word'];
      if (word is! String || word.isEmpty) {
        throw FormatException("kana word(id=$id): 'word' must be non-empty String");
      }
      final meaning = raw['meaning'];
      if (meaning is! String) {
        throw FormatException("kana word(id=$id): 'meaning' must be String");
      }
      result.add(
        Word(
          id: id,
          levelCode: level,
          act: Act.N,
          word: word,
          reading: null,
          meaning: meaning,
          isRead: false,
          wrongCnt: 0,
          exampleIds: const [],
        ),
      );
    }
  }
  return result;
}
