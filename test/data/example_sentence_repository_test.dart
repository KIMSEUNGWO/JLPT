import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/example_sentence_repository.dart';
import 'package:jlpt_app/domain/example_sentence.dart';
import 'package:pub_semver/pub_semver.dart';

AppDatabase _inMemoryDb() => AppDatabase.forTesting(NativeDatabase.memory());

final _v1 = Version.parse('1.0.0');
final _v2 = Version.parse('1.0.1');

ExampleSentence _ex(int id) =>
    ExampleSentence(id: id, sentence: '文$id', translation: '문장$id');

void main() {
  late AppDatabase db;
  late ExampleSentenceRepository repo;

  setUp(() {
    db = _inMemoryDb();
    repo = ExampleSentenceRepository(
      db,
      AppMetaRepository(db),
      courseId: 'jlpt_ja',
    );
  });

  tearDown(() => db.close());

  group('ExampleSentenceRepository', () {
    test('원격에서 빠진 예문은 DB 에서도 삭제된다', () async {
      await repo.syncAll(
        examples: [_ex(1), _ex(2), _ex(3)],
        wordExampleRefs: const {},
        version: _v1,
      );
      expect(await repo.countExamples(), 3);

      // 2 가 빠진 새 데이터셋으로 재sync → 2 는 삭제되어야 한다.
      await repo.syncAll(
        examples: [_ex(1), _ex(3)],
        wordExampleRefs: const {},
        version: _v2,
      );

      expect(await repo.countExamples(), 2);
      expect(
        (await repo.getAll()).map((e) => e.id),
        unorderedEquals([1, 3]),
      );
    });
  });
}
