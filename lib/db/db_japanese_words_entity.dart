

import 'package:jlpt_app/domain/word.dart';

class JapanWordsEntity {

  final List<Word> words;

  JapanWordsEntity({required this.words});

  JapanWordsEntity.fromJson(Map<String, dynamic> json):
    words = List<Word>.from(json['words'].map((char) => Word.fromJson(char)));
}