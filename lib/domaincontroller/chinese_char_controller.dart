
import 'package:flutter/material.dart';
import 'package:jlpt_app/domain/chinese_char.dart';

class ChineseCharController {

  static const ChineseCharController instance = ChineseCharController();
  const ChineseCharController();

  static final Map<String, ChineseChar> _map = {};

  putWord(Map<String, dynamic> json) {
    _map.addAll({
      for (var char in List<ChineseChar>.from(json['chars'].map((char) => ChineseChar.fromJson(char))))
        (char).char : char
    });
  }

  List<Widget> toWidget(List<ChineseChar> chars, Widget Function(ChineseChar char) map) {
    if (chars.isEmpty) return [];

    return chars
        .expand((entry) => [
      map(entry),
      const SizedBox(height: 10,)
    ],).toList()..removeLast();
  }

  List<ChineseChar> findChars(String word) {
    return word.characters
        .map((char) => _map[char]) // null이 포함될 수 있음
        .where((char) => char != null) // null 제거
        .cast<ChineseChar>() // List<ChineseChar?>를 List<ChineseChar>로 변환
        .toList();
  }
}