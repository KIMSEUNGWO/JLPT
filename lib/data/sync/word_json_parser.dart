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
