import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/core/app_utils.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/remote/json_data_source.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/chinese_char_repository.dart';
import 'package:jlpt_app/data/repositories/daily_stats_repository.dart';
import 'package:jlpt_app/data/repositories/example_sentence_repository.dart';
import 'package:jlpt_app/data/repositories/test_result_repository.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/data/sync/chinese_char_syncer.dart';
import 'package:jlpt_app/data/sync/course_sync_bundle.dart';
import 'package:jlpt_app/data/sync/data_sync_service.dart';
import 'package:jlpt_app/data/sync/example_sentence_syncer.dart';
import 'package:jlpt_app/data/sync/update_service.dart';
import 'package:jlpt_app/data/sync/word_syncer.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domain/course/course.dart';
import 'package:jlpt_app/domain/course/course_data_config.dart';
import 'package:jlpt_app/domain/course/course_registry.dart';
import 'package:jlpt_app/domain/example_sentence.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';

// ───────── 인프라 ─────────

// main() 에서 ProviderScope.overrides 로 주입
final appDatabaseProvider = Provider<AppDatabase>(
  (_) => throw UnimplementedError(
    'AppDatabase must be overridden in ProviderScope',
  ),
);

/// 활성 코스. 데이터/sync/UI 가 의존하는 단일 진입점.
///
/// 지금은 단일 코스라 [CourseRegistry.defaultCourse] 상수다. 코스 선택 UI 가
/// 생기면 설정에서 읽은 id 로 `CourseRegistry.byId(...)` 를 반환하도록 이 한 곳만 바꾼다.
final activeCourseProvider = Provider<Course>(
  (_) => CourseRegistry.defaultCourse,
);

final activeCourseIdProvider = Provider<String>(
  (ref) => ref.watch(activeCourseProvider).identity.id,
);

final activeCourseDataProvider = Provider<CourseDataConfig>(
  (ref) => ref.watch(activeCourseProvider).data,
);

// JSON 데이터 소스
final assetJsonDataSourceProvider = Provider<AssetJsonDataSource>(
  (_) => const AssetJsonDataSource(),
);

final localJsonCacheProvider = Provider<LocalJsonCacheSource>(
  (_) => LocalJsonCacheSource(),
);

final remoteJsonDataSourceProvider = Provider<RemoteJsonDataSource>((ref) {
  final data = ref.watch(activeCourseDataProvider);
  final source = RemoteJsonDataSource(urlsByName: data.remoteUrls);
  ref.onDispose(source.close);
  return source;
});

// ───────── Repositories ─────────

final appMetaRepositoryProvider = Provider<AppMetaRepository>(
  (ref) => AppMetaRepository(ref.read(appDatabaseProvider)),
);

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final course = ref.watch(activeCourseProvider);
  return WordRepository(
    ref.read(appDatabaseProvider),
    ref.read(appMetaRepositoryProvider),
    courseId: course.id,
    levelOf: course.levelOrNull,
  );
});

final chineseCharRepositoryProvider = Provider<ChineseCharRepository>(
  (ref) => ChineseCharRepository(
    ref.read(appDatabaseProvider),
    ref.read(appMetaRepositoryProvider),
    courseId: ref.watch(activeCourseIdProvider),
  ),
);

final exampleSentenceRepositoryProvider = Provider<ExampleSentenceRepository>(
  (ref) => ExampleSentenceRepository(
    ref.read(appDatabaseProvider),
    ref.read(appMetaRepositoryProvider),
    courseId: ref.watch(activeCourseIdProvider),
  ),
);

final testResultRepositoryProvider = Provider<TestResultRepository>((ref) {
  final course = ref.watch(activeCourseProvider);
  return TestResultRepository(
    ref.read(appDatabaseProvider),
    ref.watch(wordRepositoryProvider),
    courseId: course.id,
    levelOf: course.levelOrNull,
  );
});

final dailyStatsRepositoryProvider = Provider<DailyStatsRepository>(
  (ref) => DailyStatsRepository(
    ref.read(appDatabaseProvider),
    ref.read(appMetaRepositoryProvider),
  ),
);

// ───────── Syncers (전략 객체) ─────────

final wordSyncerProvider = Provider<WordSyncer>((ref) {
  final courseId = ref.watch(activeCourseIdProvider);
  final data = ref.watch(activeCourseDataProvider);
  return WordSyncer(
    wordRepository: ref.watch(wordRepositoryProvider),
    metaRepository: ref.read(appMetaRepositoryProvider),
    courseId: courseId,
    bundle: ref.read(assetJsonDataSourceProvider),
    cache: ref.read(localJsonCacheProvider),
    dataKey: data.wordsKey,
    expectedMinRowCount: data.minWordCount,
  );
});

/// 문자(한자) syncer — 문자 모듈이 없는 코스는 null.
final chineseCharSyncerProvider = Provider<ChineseCharSyncer?>((ref) {
  final data = ref.watch(activeCourseDataProvider);
  final charsKey = data.charsKey;
  if (charsKey == null) return null;
  return ChineseCharSyncer(
    charRepository: ref.watch(chineseCharRepositoryProvider),
    metaRepository: ref.read(appMetaRepositoryProvider),
    courseId: ref.watch(activeCourseIdProvider),
    bundle: ref.read(assetJsonDataSourceProvider),
    cache: ref.read(localJsonCacheProvider),
    dataKey: charsKey,
    expectedMinRowCount: data.minCharCount,
  );
});

final exampleSentenceSyncerProvider = Provider<ExampleSentenceSyncer>((ref) {
  final data = ref.watch(activeCourseDataProvider);
  return ExampleSentenceSyncer(
    exampleRepository: ref.watch(exampleSentenceRepositoryProvider),
    metaRepository: ref.read(appMetaRepositoryProvider),
    courseId: ref.watch(activeCourseIdProvider),
    wordsDataKey: data.wordsKey,
    bundle: ref.read(assetJsonDataSourceProvider),
    cache: ref.read(localJsonCacheProvider),
    dataKey: data.examplesKey,
    expectedMinRowCount: data.minExampleCount,
  );
});

final courseSyncBundleProvider = Provider<CourseSyncBundle>(
  (ref) => CourseSyncBundle(
    data: ref.watch(activeCourseDataProvider),
    wordSyncer: ref.watch(wordSyncerProvider),
    charSyncer: ref.watch(chineseCharSyncerProvider),
    exampleSyncer: ref.watch(exampleSentenceSyncerProvider),
  ),
);

// ───────── 부팅 / 업데이트 서비스 ─────────

final dataSyncServiceProvider = Provider<DataSyncService>(
  (ref) => DataSyncService(
    versionKey: ref.watch(activeCourseDataProvider).versionKey,
    bundle: ref.read(assetJsonDataSourceProvider),
    cache: ref.read(localJsonCacheProvider),
    remote: ref.watch(remoteJsonDataSourceProvider),
    syncers: ref.watch(courseSyncBundleProvider).syncers,
    metaRepository: ref.read(appMetaRepositoryProvider),
    dailyStatsRepository: ref.read(dailyStatsRepositoryProvider),
  ),
);

final updateServiceProvider = Provider<UpdateService>(
  (ref) => UpdateService(
    syncBundle: ref.watch(courseSyncBundleProvider),
    remote: ref.watch(remoteJsonDataSourceProvider),
    cache: ref.read(localJsonCacheProvider),
    dataSyncService: ref.watch(dataSyncServiceProvider),
  ),
);

// ───────── 파생 데이터 ─────────

/// 문자(한자) 인메모리 캐시
final chineseCharCacheProvider = FutureProvider<Map<String, ChineseChar>>(
  (ref) => ref.watch(chineseCharRepositoryProvider).getAll(),
);

/// 레벨별 단어 목록 — 홈 화면에서 전역으로 공유
final wordsByLevelProvider = FutureProvider<Map<Level, List<Word>>>(
  (ref) => ref.watch(wordRepositoryProvider).getAllByLevel(),
);

/// 한 단어에 연결된 예문 본문 목록. 카드 상세에서 lazy 로 watch.
final exampleSentencesByWordProvider = FutureProvider.autoDispose
    .family<List<ExampleSentence>, int>(
      (ref, wordId) =>
          ref.watch(exampleSentenceRepositoryProvider).getByWordId(wordId),
    );

/// 특정 레벨의 테스트 통계 (최근 점수, 총 횟수)
typedef TestStats = ({int count, String recentScore});

final testStatsByLevelProvider = FutureProvider.autoDispose
    .family<TestStats, Level?>((ref, level) async {
      final results = await ref.watch(testResultRepositoryProvider).getAll();
      final relevant = results.where((r) => r.level == level).toList();
      final count = relevant.length;
      String recentScore = '0%';
      if (relevant.isNotEmpty) {
        final qs = relevant.first.question;
        recentScore = correctRatePercent(
          qs.where((q) => q.isCorrect).length,
          qs.length,
        );
      }
      return (count: count, recentScore: recentScore);
    });

/// 오늘 포함 최근 7일의 일별 통계 (빈 날은 0 row 로 채움).
///
/// autoDispose — 홈 화면이 watch 할 때만 살아있음. 학습 중 `_recordStats` 의
/// 빈번한 `invalidate` 가 listener 없을 때 즉시 재실행되는 것을 막는다.
final weeklyStatsProvider = FutureProvider.autoDispose<List<DailyStatData>>(
  (ref) => ref.read(dailyStatsRepositoryProvider).getThisWeek(),
);

/// 현재 스트릭 + 역대 최고 스트릭.
typedef StreakSnapshot = ({int current, int best});

final studyStreakProvider = FutureProvider.autoDispose<StreakSnapshot>((
  ref,
) async {
  final repo = ref.read(dailyStatsRepositoryProvider);
  return (current: await repo.getStreak(), best: await repo.getBestStreak());
});
