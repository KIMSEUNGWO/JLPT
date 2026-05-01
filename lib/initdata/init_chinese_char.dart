import 'package:jlpt_app/component/json_reader.dart';
import 'package:jlpt_app/data/repositories/chinese_char_repository.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/initdata/init_data_helper.dart';

class InitChineseCharHelper extends InitDataHelper<ChineseChar> {
  final ChineseCharRepository _repo;

  InitChineseCharHelper(this._repo);

  @override
  String get logTag => 'Chinese Char';

  @override
  Future<bool> hasData() => _repo.hasChars();

  @override
  Future<List<ChineseChar>> load() async {
    final json = await JsonReader.loadJson('chinese_chars');
    return (json['chars'] as List)
        .map((e) => ChineseChar.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> sync(List<ChineseChar> items) => _repo.syncAll(items);
}
