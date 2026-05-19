import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/core/app_utils.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/remote/json_data_source.dart';
import 'package:jlpt_app/data/repositories/app_meta_repository.dart';
import 'package:jlpt_app/data/repositories/chinese_char_repository.dart';
import 'package:jlpt_app/data/repositories/daily_stats_repository.dart';
import 'package:jlpt_app/data/repositories/test_result_repository.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/data/sync/chinese_char_syncer.dart';
import 'package:jlpt_app/data/sync/data_sync_service.dart';
import 'package:jlpt_app/data/sync/update_service.dart';
import 'package:jlpt_app/data/sync/word_syncer.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domain/constant.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';

// ───────── 인프라 ─────────

// main() 에서 ProviderScope.overrides 로 주입
final appDatabaseProvider = Provider<AppDatabase>(
  (_) => throw UnimplementedError(
    'AppDatabase must be overridden in ProviderScope',
  ),
);

// JSON 데이터 소스
final assetJsonDataSourceProvider = Provider<AssetJsonDataSource>(
  (_) => const AssetJsonDataSource(),
);

final localJsonCacheProvider = Provider<LocalJsonCacheSource>(
  (_) => LocalJsonCacheSource(),
);

final remoteJsonDataSourceProvider = Provider<RemoteJsonDataSource>(
  (ref) {
    final source = RemoteJsonDataSource(
      urlsByName: {
        'dataVersion': Constant.VERSION_LINK,
        'chinese_chars': Constant.CHINESE_CHARS_LINK,
        'japanese_words': Constant.JAPANESE_WORDS_LINK,
      },
    );
    ref.onDispose(source.close);
    return source;
  },
);

// ───────── Repositories ─────────

final appMetaRepositoryProvider = Provider<AppMetaRepository>(
  (ref) => AppMetaRepository(ref.read(appDatabaseProvider)),
);

final wordRepositoryProvider = Provider<WordRepository>(
  (ref) => WordRepository(
    ref.read(appDatabaseProvider),
    ref.read(appMetaRepositoryProvider),
  ),
);

final chineseCharRepositoryProvider = Provider<ChineseCharRepository>(
  (ref) => ChineseCharRepository(
    ref.read(appDatabaseProvider),
    ref.read(appMetaRepositoryProvider),
  ),
);

final testResultRepositoryProvider = Provider<TestResultRepository>(
  (ref) => TestResultRepository(
    ref.read(appDatabaseProvider),
    ref.read(wordRepositoryProvider),
  ),
);

final dailyStatsRepositoryProvider = Provider<DailyStatsRepository>(
  (ref) => DailyStatsRepository(
    ref.read(appDatabaseProvider),
    ref.read(appMetaRepositoryProvider),
  ),
);

// ───────── Syncers (전략 객체) ─────────

final wordSyncerProvider = Provider<WordSyncer>(
  (ref) => WordSyncer(
    wordRepository: ref.read(wordRepositoryProvider),
    metaRepository: ref.read(appMetaRepositoryProvider),
    bundle: ref.read(assetJsonDataSourceProvider),
    cache: ref.read(localJsonCacheProvider),
  ),
);

final chineseCharSyncerProvider = Provider<ChineseCharSyncer>(
  (ref) => ChineseCharSyncer(
    charRepository: ref.read(chineseCharRepositoryProvider),
    metaRepository: ref.read(appMetaRepositoryProvider),
    bundle: ref.read(assetJsonDataSourceProvider),
    cache: ref.read(localJsonCacheProvider),
  ),
);

// ───────── 부팅 / 업데이트 서비스 ─────────

final dataSyncServiceProvider = Provider<DataSyncService>(
  (ref) => DataSyncService(
    bundle: ref.read(assetJsonDataSourceProvider),
    cache: ref.read(localJsonCacheProvider),
    remote: ref.read(remoteJsonDataSourceProvider),
    wordSyncer: ref.read(wordSyncerProvider),
    charSyncer: ref.read(chineseCharSyncerProvider),
    metaRepository: ref.read(appMetaRepositoryProvider),
    dailyStatsRepository: ref.read(dailyStatsRepositoryProvider),
  ),
);

final updateServiceProvider = Provider<UpdateService>(
  (ref) => UpdateService(
    remote: ref.read(remoteJsonDataSourceProvider),
    cache: ref.read(localJsonCacheProvider),
    wordSyncer: ref.read(wordSyncerProvider),
    charSyncer: ref.read(chineseCharSyncerProvider),
    dataSyncService: ref.read(dataSyncServiceProvider),
  ),
);

// ───────── 파생 데이터 ─────────

/// 한자 인메모리 캐시
final chineseCharCacheProvider = FutureProvider<Map<String, ChineseChar>>(
  (ref) => ref.read(chineseCharRepositoryProvider).getAll(),
);

/// 레벨별 단어 목록 — 홈 화면에서 전역으로 공유
final wordsByLevelProvider = FutureProvider<Map<Level, List<Word>>>(
  (ref) => ref.read(wordRepositoryProvider).getAllByLevel(),
);

/// 특정 레벨의 테스트 통계 (최근 점수, 총 횟수)
typedef TestStats = ({int count, String recentScore});

final testStatsByLevelProvider =
    FutureProvider.autoDispose.family<TestStats, Level?>((ref, level) async {
  final results = await ref.read(testResultRepositoryProvider).getAll();
  final relevant = results.where((r) => r.level == level).toList();
  final count = relevant.length;
  String recentScore = '0%';
  if (relevant.isNotEmpty) {
    final qs = relevant.first.question;
    recentScore =
        correctRatePercent(qs.where((q) => q.isCorrect).length, qs.length);
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

final studyStreakProvider =
    FutureProvider.autoDispose<StreakSnapshot>((ref) async {
  final repo = ref.read(dailyStatsRepositoryProvider);
  return (current: await repo.getStreak(), best: await repo.getBestStreak());
});
