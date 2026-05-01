import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/data/database/app_database.dart';
import 'package:jlpt_app/data/repositories/chinese_char_repository.dart';
import 'package:jlpt_app/data/repositories/test_result_repository.dart';
import 'package:jlpt_app/data/repositories/word_repository.dart';
import 'package:jlpt_app/core/app_utils.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';

// main()에서 ProviderScope.overrides로 주입
final appDatabaseProvider = Provider<AppDatabase>(
  (_) => throw UnimplementedError('AppDatabase must be overridden in ProviderScope'),
);

final wordRepositoryProvider = Provider<WordRepository>(
  (ref) => WordRepository(ref.read(appDatabaseProvider)),
);

final chineseCharRepositoryProvider = Provider<ChineseCharRepository>(
  (ref) => ChineseCharRepository(ref.read(appDatabaseProvider)),
);

final testResultRepositoryProvider = Provider<TestResultRepository>(
  (ref) => TestResultRepository(
    ref.read(appDatabaseProvider),
    ref.read(wordRepositoryProvider),
  ),
);

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
    FutureProvider.family<TestStats, Level?>((ref, level) async {
  final results = await ref.read(testResultRepositoryProvider).getAll();
  final relevant = results.where((r) => r.level == level).toList();
  final count = relevant.length;
  String recentScore = '0%';
  if (relevant.isNotEmpty) {
    final qs = relevant.first.question;
    recentScore = correctRatePercent(qs.where((q) => q.isCorrect).length, qs.length);
  }
  return (count: count, recentScore: recentScore);
});
