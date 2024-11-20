
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/domain/word_extra.dart';

class JapaneseWordController {

  // static const JapaneseWordController instance = JapaneseWordController();
  // const JapaneseWordController();
  //
  // static final Map<Level, List<WordExtra>> _map = {};
  //
  // putWord(Map<String, dynamic> json) {
  //
  //   var readWordIdList = LocalStorage.instance.getReadWordIdList();
  //
  //   (json['words'] as List).map((w) => WordExtra.fromJson(w))
  //       .forEach((word) {
  //         _map.putIfAbsent(word.level, () => []).add(word);
  //         if (readWordIdList.contains(word.id)) word.isRead = true;
  //   });
  //
  // }
  //
  // List<WordExtra> getAllExtra() {
  //   return _map.values.expand((element) => element,).toList();
  // }
  //
  // List<Word> getLevelWords(Level level) => _map[level] ?? [];
  //
  // int getLevelSize(Level level) => _map[level]?.length ?? 100;
  // int getOnlyReadSize(Level level) {
  //   return _map[level]?.where((word) => word.isRead).length ?? 0;
  // }

}