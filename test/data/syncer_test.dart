import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/remote/json_data_source.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/data/sync/word_syncer.dart';
import 'package:pub_semver/pub_semver.dart';

/// JsonDataSource 의 in-memory 구현 — 외부 의존 없이 syncer 테스트.
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
      'words': [
        for (var i = 1; i <= count; i++)
          {
            'id': i,
            'level': 'N5',
            'act': 'N',
            'word': '単$i',
            'hiragana': 'たん$i',
            'korean': '단$i',
          },
      ],
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
    repo = WordRepository(db, meta);
    syncer = WordSyncer(
      wordRepository: repo,
      metaRepository: meta,
      bundle: const AssetJsonDataSource(),
      cache: LocalJsonCacheSource(),
      // fixture 크기에 맞춰 lower bound 낮춤
      expectedMinRowCount: 2,
    );
  });

  tearDown(() => db.close());

  group('JsonEntitySyncer (WordSyncer)', () {
    test('첫 부팅: DB 비어있고 메타도 비어있을 때 sync', () async {
      expect(await syncer.isUpToDate(v1), isFalse);
      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': _wordsJson(10)}),
        version: v1,
      );
      expect(await syncer.isUpToDate(v1), isTrue);
      expect(await repo.countWords(), 10);
      expect(await meta.getWordsVersion(), v1);
    });

    test('정상 sync 후 같은 버전이면 isUpToDate=true', () async {
      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': _wordsJson(10)}),
        version: v1,
      );
      expect(await syncer.isUpToDate(v1), isTrue);
    });

    test('버전이 다르면 isUpToDate=false → 재동기화 필요', () async {
      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': _wordsJson(10)}),
        version: v1,
      );
      expect(await syncer.isUpToDate(v2), isFalse);
    });

    test('부분 DB 감지: row 수가 expectedMin 미만이면 isUpToDate=false', () async {
      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': _wordsJson(10)}),
        version: v1,
      );
      // 의도적으로 1개만 남기고 삭제 → 부분 DB 시뮬레이션.
      await db.customStatement('DELETE FROM words WHERE id > 1');
      expect(await repo.countWords(), 1);
      expect(await syncer.isUpToDate(v1), isFalse,
          reason: 'expectedMinRowCount 미만이면 재동기화 트리거되어야 한다');
    });

    test('파싱 실패는 DB 를 건드리지 않는다', () async {
      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': _wordsJson(10)}),
        version: v1,
      );
      final before = await repo.countWords();

      final bad = <String, dynamic>{
        'words': [
          {
            'id': 'not-an-int',
            'level': 'N5',
            'act': 'N',
            'word': '?',
            'hiragana': '?',
            'korean': '?',
          },
        ],
      };
      await expectLater(
        syncer.syncFrom(
          source: _InMemorySource({'japanese_words': bad}),
          version: v2,
        ),
        throwsA(isA<FormatException>()),
      );
      expect(await repo.countWords(), before,
          reason: '파싱 실패 시 DB 가 변경되지 않아야 한다');
      expect(await meta.getWordsVersion(), v1,
          reason: '메타 버전도 유지되어야 한다');
    });

    test('동일 내용 중복 id 는 skip 되고 sync 성공', () async {
      // 같은 id + 정확히 같은 내용 = 무해한 데이터 중복.
      final payload = <String, dynamic>{
        'words': [
          {
            'id': 1,
            'level': 'N5',
            'act': 'N',
            'word': 'same',
            'hiragana': 'same',
            'korean': 'same',
          },
          {
            'id': 1,
            'level': 'N5',
            'act': 'N',
            'word': 'same',
            'hiragana': 'same',
            'korean': 'same',
          },
          {
            'id': 2,
            'level': 'N5',
            'act': 'N',
            'word': 'other',
            'hiragana': 'other',
            'korean': 'other',
          },
        ],
      };
      await syncer.syncFrom(
        source: _InMemorySource({'japanese_words': payload}),
        version: v1,
      );
      expect(await repo.countWords(), 2,
          reason: '동일 내용 중복은 dedupe 되어야 한다');
    });

    test('내용이 다른 중복 id 는 파싱 실패로 처리된다', () async {
      // 같은 id + 다른 내용 = 진짜 충돌. 어느 게 진짜인지 모르므로 거부.
      final bad = <String, dynamic>{
        'words': [
          {
            'id': 1,
            'level': 'N5',
            'act': 'N',
            'word': 'a',
            'hiragana': 'a',
            'korean': 'a',
          },
          {
            'id': 1,
            'level': 'N5',
            'act': 'N',
            'word': 'b',
            'hiragana': 'b',
            'korean': 'b',
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
  });
}
