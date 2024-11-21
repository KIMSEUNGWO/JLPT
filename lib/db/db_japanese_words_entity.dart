

import 'package:jlpt_app/domain/word.dart';

class JapanWordsEntity {

  final String version;
  final List<Word> words;
  // final List<Word> words;

  JapanWordsEntity({required this.version, required this.words});

  JapanWordsEntity.fromJson(Map<String, dynamic> json):
    version = json['version'],
    words = List<Word>.from(json['words'].map((char) => Word.fromJson(char)));
}