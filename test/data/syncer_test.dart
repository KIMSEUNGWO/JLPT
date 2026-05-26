import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/remote/json_data_source.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/data/sync/word_syncer.dart';
import 'package:jlpt_app/domain/course/course_registry.dart';
import 'package:pub_semver/pub_semver.dart';

class _InMemorySource implements JsonDataSource {
  _InMemorySource(this._payloads);
  final Map<String, Map<String, dynamic>> _payloads;

  @override
  Future<Map<String, dynamic>> read(String name) async {
    final p = _payloads[name];
    if (p == null) throw StateError('no payload for $name');
    return p;
  }
}

Map<String, dynamic> _wordsJson(int count) => {
  'words': {
    'N5': [
      for (var i = 1; i <= count; i++)
        {
          'id': i,
          'act': 'N',
          'word': 'word$i',
          'hiragana': 'reading$i',
          'korean': 'meaning$i',
          'exampleIds': [100000 + i],
        },
    ],
  },
};

void main() {
  late AppDatabase db;
  late AppMetaRepository meta;
  late WordRepository repo;
  late WordSyncer syncer;

  final v1 = Version.parse('1.0.0');
  final v2 = Version.parse('1.0.1');

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    meta = AppMetaRepository(db);
    repo = WordRepository(
      db,
      meta,
      courseId: jlptJapaneseCourse.id,
      levelOf: jlptJapaneseCourse.levelOrNull,
    );
    syncer = WordSyncer(
      wordRepository: repo,
      metaRepository: meta,
      courseId: jlptJapaneseCourse.id,
      bundle: const AssetJsonDataSource(),
      cache: LocalJsonCacheSource(),
      dataKey: jlptJapaneseCourse.data.wordsKey,
      expectedMinRowCount: 2,
    );
  });

  tearDown(() => db.close());

  group('WordSyncer', () {
    test('syncs grouped words into an empty db', () async {
      expect(await syncer.isUpToDate(v1), isFalse);

      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': _wordsJson(10)}),
        version: v1,
      );

      expect(await syncer.isUpToDate(v1), isTrue);
      expect(await repo.countWords(), 10);
      expect(await meta.getWordsVersion('jlpt_ja'), v1);
    });

    test('sets grouped level key as each word level', () async {
      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': _wordsJson(10)}),
        version: v1,
      );

      final words = await repo.getByLevel(jlptJapaneseCourse.levelOrNull('N5')!);
      expect(words, hasLength(10));
      expect(words.every((word) => word.levelCode == 'N5'), isTrue);
    });

    test('isUpToDate is true after sync with same version', () async {
      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': _wordsJson(10)}),
        version: v1,
      );

      expect(await syncer.isUpToDate(v1), isTrue);
    });

    test('isUpToDate is false when remote version differs', () async {
      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': _wordsJson(10)}),
        version: v1,
      );

      expect(await syncer.isUpToDate(v2), isFalse);
    });

    test('isUpToDate is false when row count is below expected minimum', () async {
      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': _wordsJson(10)}),
        version: v1,
      );
      await db.customStatement('DELETE FROM words WHERE id > 1');

      expect(await repo.countWords(), 1);
      expect(await syncer.isUpToDate(v1), isFalse);
    });

    test('parse failure leaves existing db and version unchanged', () async {
      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': _wordsJson(10)}),
        version: v1,
      );
      final before = await repo.countWords();

      final bad = <String, dynamic>{
        'words': {
          'N5': [
            {
              'id': 'not-an-int',
              'act': 'N',
              'word': '?',
              'hiragana': '?',
              'korean': '?',
              'exampleIds': [100001],
            },
          ],
        },
      };

      await expectLater(
        syncer.syncFrom(
          source: _InMemorySource({'japanese_words': bad}),
          version: v2,
        ),
        throwsA(isA<FormatException>()),
      );
      expect(await repo.countWords(), before);
      expect(await meta.getWordsVersion('jlpt_ja'), v1);
    });

    test('flat words array is rejected', () async {
      final bad = <String, dynamic>{
        'words': [
          {
            'id': 1,
            'level': 'N5',
            'act': 'N',
            'word': 'a',
            'hiragana': 'a',
            'korean': 'a',
            'exampleIds': [100001],
          },
        ],
      };

      await expectLater(
        syncer.syncFrom(
          source: _InMemorySource({'japanese_words': bad}),
          version: v1,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('same-content duplicate ids are deduped', () async {
      final payload = <String, dynamic>{
        'words': {
          'N5': [
            {
              'id': 1,
              'act': 'N',
              'word': 'same',
              'hiragana': 'same',
              'korean': 'same',
              'exampleIds': [100001],
            },
            {
              'id': 1,
              'act': 'N',
              'word': 'same',
              'hiragana': 'same',
              'korean': 'same',
              'exampleIds': [100001],
            },
            {
              'id': 2,
              'act': 'N',
              'word': 'other',
              'hiragana': 'other',
              'korean': 'other',
              'exampleIds': [100002],
            },
          ],
        },
      };

      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': payload}),
        version: v1,
      );

      expect(await repo.countWords(), 2);
    });

    test('different-content duplicate ids are rejected', () async {
      final bad = <String, dynamic>{
        'words': {
          'N5': [
            {
              'id': 1,
              'act': 'N',
              'word': 'a',
              'hiragana': 'a',
              'korean': 'a',
              'exampleIds': [100001],
            },
            {
              'id': 1,
              'act': 'N',
              'word': 'b',
              'hiragana': 'b',
              'korean': 'b',
              'exampleIds': [100002],
            },
          ],
        },
      };

      await expectLater(
        syncer.syncFrom(
          source: _InMemorySource({'japanese_words': bad}),
          version: v1,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
