import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/initdata/init_data_helper.dart';

class InitJapanWordHelper extends InitDataHelper<Word> {
  final WordRepository _repo;

  InitJapanWordHelper(this._repo);

  @override
  String get logTag => 'Japan Word';

  @override
  Future<bool> hasData() => _repo.hasWords();

  @override
  Future<List<Word>> load() async {
    final json = await JsonReader.loadJson('japanese_words');
    return (json['words'] as List)
        .map((e) => Word.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> sync(List<Word> items) => _repo.syncAll(items);
}
