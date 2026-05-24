import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/remote/json_data_source.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/chinese_char_repository.dart';
import 'package:jlpt_app/data/repositories/daily_stats_repository.dart';
import 'package:jlpt_app/data/repositories/example_sentence_repository.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/data/sync/chinese_char_syncer.dart';
import 'package:jlpt_app/data/sync/course_sync_bundle.dart';
import 'package:jlpt_app/data/sync/data_sync_service.dart';
import 'package:jlpt_app/data/sync/example_sentence_syncer.dart';
import 'package:jlpt_app/data/sync/update_service.dart';
import 'package:jlpt_app/data/sync/word_syncer.dart';
import 'package:jlpt_app/domain/course/course_data_config.dart';
import 'package:jlpt_app/domain/course/course_registry.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  late AppDatabase db;
  late AppMetaRepository meta;

  const data = CourseDataConfig(
    versionKey: 'dataVersion',
    wordsKey: 'words',
    charsKey: 'chars',
    examplesKey: 'examples',
    remoteUrls: {
      'dataVersion': 'https://example.test/dataVersion.json',
      'words': 'https://example.test/words.json',
      'chars': 'https://example.test/chars.json',
      'examples': 'https://example.test/examples.json',
    },
    minWordCount: 1,
    minCharCount: 1,
    minExampleCount: 1,
  );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    meta = AppMetaRepository(db);
  });

  tearDown(() => db.close());

  test('checkForUpdate 는 일부 syncer 만 뒤처져도 업데이트를 반환한다', () async {
    final remoteVersion = Version.parse('2.0.0');
    await meta.markWordsSynced(remoteVersion, jlptJapaneseCourse.id);
    await meta.markCharsSynced(remoteVersion, jlptJapaneseCourse.id);
    await meta.markExamplesSynced(
      Version.parse('1.0.0'),
      jlptJapaneseCourse.id,
    );

    final service = makeUpdateService(data, db: db, meta: meta);

    final plan = await service.checkForUpdate();

    expect(plan, isNotNull);
    expect(plan!.version, remoteVersion);
  });

  test('checkForUpdate 는 모든 syncer 가 최신이면 null 을 반환한다', () async {
    final remoteVersion = Version.parse('2.0.0');
    await meta.markWordsSynced(remoteVersion, jlptJapaneseCourse.id);
    await meta.markCharsSynced(remoteVersion, jlptJapaneseCourse.id);
    await meta.markExamplesSynced(remoteVersion, jlptJapaneseCourse.id);

    final service = makeUpdateService(data, db: db, meta: meta);

    expect(await service.checkForUpdate(), isNull);
  });
}

UpdateService makeUpdateService(
  CourseDataConfig data, {
  required AppDatabase db,
  required AppMetaRepository meta,
}) {
  final remote = RemoteJsonDataSource(
    urlsByName: data.remoteUrls,
    client: MockClient((request) async {
      if (request.method == 'HEAD') {
        return http.Response('', 200, headers: {'content-length': '10'});
      }
      return http.Response(
        jsonEncode({
          'version': '2.0.0',
          'description': 'test',
          'last_updated': '2026-05-24',
        }),
        200,
      );
    }),
  );
  final bundle = const AssetJsonDataSource();
  final cache = LocalJsonCacheSource();
  final wordRepo = WordRepository(
    db,
    meta,
    courseId: jlptJapaneseCourse.id,
    levelOf: jlptJapaneseCourse.levelOrNull,
  );
  final charRepo = ChineseCharRepository(
    db,
    meta,
    courseId: jlptJapaneseCourse.id,
  );
  final exampleRepo = ExampleSentenceRepository(
    db,
    meta,
    courseId: jlptJapaneseCourse.id,
  );
  final wordSyncer = WordSyncer(
    wordRepository: wordRepo,
    metaRepository: meta,
    courseId: jlptJapaneseCourse.id,
    bundle: bundle,
    cache: cache,
    dataKey: data.wordsKey,
    expectedMinRowCount: data.minWordCount,
  );
  final charSyncer = ChineseCharSyncer(
    charRepository: charRepo,
    metaRepository: meta,
    courseId: jlptJapaneseCourse.id,
    bundle: bundle,
    cache: cache,
    dataKey: data.charsKey!,
    expectedMinRowCount: data.minCharCount,
  );
  final exampleSyncer = ExampleSentenceSyncer(
    exampleRepository: exampleRepo,
    metaRepository: meta,
    courseId: jlptJapaneseCourse.id,
    wordsDataKey: data.wordsKey,
    bundle: bundle,
    cache: cache,
    dataKey: data.examplesKey,
    expectedMinRowCount: data.minExampleCount,
  );
  final syncBundle = CourseSyncBundle(
    data: data,
    wordSyncer: wordSyncer,
    charSyncer: charSyncer,
    exampleSyncer: exampleSyncer,
  );
  final dataSyncService = DataSyncService(
    versionKey: data.versionKey,
    bundle: bundle,
    cache: cache,
    remote: remote,
    syncers: syncBundle.syncers,
    metaRepository: meta,
    dailyStatsRepository: DailyStatsRepository(db, meta),
  );
  return UpdateService(
    syncBundle: syncBundle,
    remote: remote,
    cache: cache,
    dataSyncService: dataSyncService,
  );
}
