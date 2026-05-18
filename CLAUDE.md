# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

JLPT GO는 JLPT N1–N5 수준별 단어·문법 학습 Flutter 앱입니다. 플래시카드 학습, 4지선다 테스트, TTS 발음 기능을 제공합니다. Drift + Riverpod 3 기반.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs

flutter analyze
dart run custom_lint
dart fix --apply

flutter test
flutter test test/data/word_repository_test.dart   # 단일 파일
flutter test --plain-name 'WordRepository'

flutter build apk
flutter build ios
```

> `@DriftDatabase`, `@DriftAccessor`, `@riverpod` 어노테이션 파일을 수정하면 반드시 `build_runner` 재실행. `.g.dart` 는 산출물 — 직접 편집 금지.

---

## Architecture

### 부팅 시퀀스 (★ 중요)

```
main()
  └─ openDatabase() + LocalStorage.initInstance()
     └─ ProviderScope(overrides: [appDatabaseProvider = db])
        └─ MaterialApp.router → GoRouter('/') → StartupGate
                                                 │
                                                 ▼  ref.watch(startupProvider)
                            ┌────────────────────┴────────────────────┐
                            ▼                                          ▼
                      DataSyncService                              SyncReport
                      .ensureSynced()                              ──┬─────────
                            │                                       │
                  ┌─────────┼──────────┐                  ┌─────────┼──────────┐
                  ▼         ▼          ▼                  ▼         ▼          ▼
              번들 버전   캐시 버전   DB 메타 버전      upToDate    synced     failed
                  └───max──┘          (compare)            │         │          │
                       │                                   ▼         ▼          ▼
                       └── isUpToDate? ──── no ──► sync ──► invalidate ──► MainPage / Retry
                                       └── yes ──────────► invalidate ──► MainPage
```

핵심:
1. **StartupGate 통과 전에는 메인 화면이 절대 mount 되지 않는다** — `wordsByLevelProvider` 가 빈 결과를 캐싱하는 경로 차단.
2. **데이터 sync 와 메타 버전 commit 은 같은 DB transaction** — 부분 commit 불가.
3. **부분 DB 자동 감지** — `isUpToDate(sourceVersion)` 가 row 수 + 메타 버전 둘 다 본다.

### 레이어 구조

```
lib/
├─ main.dart               # Drift DB open + LocalStorage init → ProviderScope
├─ app/
│  ├─ app.dart             # MaterialApp.router
│  ├─ router.dart          # appRouter (GoRouter)
│  ├─ app_routes.dart      # 라우트 경로 상수 (AppRoutes)
│  ├─ route_args.dart      # sealed RouteArgs + 4 구현 (typed extra)
│  └─ bootstrap.dart       # openDatabase()
├─ core/
│  ├─ theme/               # AppTheme.light, AppColors
│  └─ app_utils.dart       # correctRatePercent 등
├─ component/              # 공용 유틸 (logger, snack_bar, svg_icon, chart …)
│  ├─ local_storage.dart   # SharedPreferences 래퍼 (모든 mutation Future<void>)
│  ├─ test_examiner.dart, question_creator.dart
│  └─ chart/pie_chart.dart
├─ data/
│  ├─ database/
│  │  ├─ app_database.dart       # @DriftDatabase, schemaVersion = 2, MigrationStrategy
│  │  ├─ tables/                 # Words, ChineseChars, TestResults, TestQuestions, AppMeta
│  │  └─ daos/                   # WordDao, ChineseCharDao, TestResultDao, AppMetaDao
│  ├─ repositories/              # Word/ChineseChar/TestResult/AppMeta Repository
│  ├─ remote/
│  │  └─ json_data_source.dart   # JsonDataSource interface + Asset/Remote/LocalCache 구현
│  ├─ sync/                      # ★ 데이터 동기화 핵심
│  │  ├─ json_entity_syncer.dart # abstract base — parse / persist / isUpToDate / syncFrom
│  │  ├─ word_syncer.dart        # WordSyncer extends JsonEntitySyncer<Word>
│  │  ├─ chinese_char_syncer.dart
│  │  ├─ data_sync_service.dart  # 부팅 sync 오케스트레이션 + SyncReport sealed
│  │  └─ update_service.dart     # 원격 신버전 다운로드/검증/적용 + UpdateStage enum
│  ├─ local/settings_repository.dart
│  └─ providers.dart             # 모든 Riverpod 프로바이더
├─ domain/                # 순수 Dart (Flutter / Drift / GoRouter import 금지)
│  ├─ word.dart, chinese_char.dart  # immutable + copyWith
│  ├─ grammar.dart, question.dart, question_box.dart (QuestionBox interface)
│  ├─ timer.dart, constant.dart
│  ├─ level.dart, act.dart, type.dart   # enum
│  ├─ question/                # QuestionGenerator<T> 전략 패턴
│  └─ box/question_entity_box.dart
├─ initdata/update/version_info.dart   # semver 기반 VersionInfo
├─ notifier/              # @riverpod codegen
│  ├─ startup_notifier.dart       → startupProvider (AsyncNotifier<SyncReport>)
│  ├─ study_session_notifier.dart → studySessionProvider
│  ├─ today_notifier.dart  → todayProvider
│  ├─ timer_notifier.dart  → timerProvider
│  ├─ study_cycle_notifier.dart → studyCycleProvider
│  ├─ recently_view_notifier.dart → recentlyViewProvider
│  └─ entity/                # Notifier 상태 데이터 (today, view)
└─ widgets/
   ├─ startup_gate.dart           # '/' 라우트 entry — splash/error/main
   ├─ update_prompt.dart          # 부팅 후 백그라운드 업데이트 안내
   ├─ page_main.dart, study/, modal/, component/
   └─ ...
```

### 핵심 원칙

- **위젯은 DB 를 모른다.** 모든 데이터 접근은 Riverpod 로 주입된 Repository.
- **Repository 는 UI 를 모른다.** `WidgetRef` 안 받음.
- **Domain 계층은 framework-free.** `Word`/`ChineseChar` 는 immutable.
- **데이터 변경은 transaction.** sync = data upsert + 메타 버전 commit 이 하나의 atomic 단위.
- **라우트 extra 는 sealed `RouteArgs`.** Map 캐스팅·Function 전달 금지.
- **Notifier 는 `@riverpod` codegen.** provider 이름은 클래스명에서 `Notifier` 접미사 제거.

---

## Drift 스키마 (schemaVersion = 2)

| 테이블 | 설명 |
|---|---|
| `Words` | 단어 (id PK, level, act, word, hiragana, korean, is_read, wrong_cnt) |
| `ChineseChars` | 한자 (char PK, korean_char, sound_reading JSON, mean_reading JSON) |
| `TestResults` | 테스트 세션 (id, level?, type, taken_at, time_seconds) |
| `TestQuestions` | 세션별 문항 (question_word_id FK, my_answer_word_id?, examples_json, is_correct, reverse) |
| `AppMeta` | 앱 메타 key-value (`words_version`, `chars_version`, `*_synced_at`, `last_sync_error`) |

Migration: `onUpgrade(from < 2) → createTable(appMeta)`. 기존 row 그대로 두고 다음 부팅에서 `DataSyncService` 가 sourceVersion 으로 재동기화.

---

## 데이터 동기화 (★ 핵심)

새 entity 종류 (예: `Grammar`) 를 sync 대상으로 추가하려면 `JsonEntitySyncer<T>` 의 5개 메서드만 구현:

```dart
final class GrammarSyncer extends JsonEntitySyncer<Grammar> {
  GrammarSyncer({
    required this.repo,
    required this.meta,
    required super.bundle,
    required super.cache,
    this.expectedMinRowCount = 100,
  }) : super(dataKey: 'grammar');

  @override List<Grammar> parse(Map<String, dynamic> json) { ... }
  @override Future<void> persist(List<Grammar> items, Version v) =>
      repo.syncAll(items, version: v);
  @override Future<Version?> currentDbVersion() => meta.getGrammarVersion();
  @override Future<int> currentDbRowCount() => repo.count();
}
```

그 다음 `DataSyncService.ensureSynced()` 와 `UpdateService.applyUpdate()` 에 추가.

---

## Riverpod 3 codegen 컨벤션

- `@riverpod` + `part 'xxx.g.dart';` 필수
- `build()` 에서 초기 상태 반환 (LocalStorage 는 `main()` 에서 이미 init)
- 일반 Provider/FutureProvider 는 `lib/data/providers.dart` 에 수동 정의
- 상태 변경: `ref.read(xProvider.notifier).method()`
- `unawaited()` 사용 시 `import 'dart:async';`

---

## go_router 라우트 테이블

| 경로 | 화면 | `state.extra` 타입 |
|---|---|---|
| `/` (`AppRoutes.root`) | `StartupGate` | - |
| `/home` (`AppRoutes.home`) | `MainPage` | - |
| `/study/:level` | `StudyListPage` | - (provider 조회) |
| `/study/:level/group` | `StudyPage` | `StudyGroupArgs` |
| `/test` | `TestPage` | `TestArgs` |
| `/test/results` | `TestResultPage` | `TestResultsArgs?` |
| `/test/results/detail` | `TestResultDetailPage` | `TestResultDetailArgs` |

```dart
context.push(AppRoutes.test, extra: TestArgs(type: ..., level: ..., mount: ...));
```

---

## 새 기능 추가 체크리스트

1. **Entity** — `lib/domain/` 루트에 immutable Dart 클래스 + `fromJson` (엄격한 타입 검증) + `copyWith`
2. **Drift 테이블** — `lib/data/database/tables/` 에 Table 추가 → `app_database.dart` `tables:` 등록 → schemaVersion 올리고 `MigrationStrategy.onUpgrade` 분기 추가 → `build_runner build`
3. **DAO** — `@DriftAccessor` → `daos:` 목록 추가 → 재빌드
4. **Repository** — 생성자에서 `AppDatabase` + 필요한 다른 repo 주입. sync 류 메서드는 `Future<void> ...(items, {required Version version})` 시그니처로 메타 commit 까지 포함
5. **Provider** — `lib/data/providers.dart` 에 추가
6. **Notifier** — `lib/notifier/` 에 `@riverpod` 추가 → 재빌드
7. **Route** — `app_routes.dart` 에 path 상수 + `route_args.dart` 에 typed args sealed 클래스 추가 → `router.dart` GoRoute 등록
8. **Widget** — `ConsumerWidget` / `ConsumerStatefulWidget`. data 의존은 provider 로 watch, side effect 는 notifier method 로

---

## 테스트

```
test/
├─ widget_test.dart                       # LocalStorage util smoke test
├─ data/word_repository_test.dart         # syncAll 보존, upsert, version commit
├─ data/app_meta_repository_test.dart     # 메타 readback / 에러 복구 / 손상 데이터
├─ data/syncer_test.dart                  # 부분 DB 감지 / 파싱 실패 rollback / 중복 id
└─ domain/question_creator_test.dart      # 4지선다 생성 로직
```

Drift 테스트는 `AppDatabase.forTesting(NativeDatabase.memory())`. mock 없이 실제 SQL 실행.

`JsonDataSource` 가 인터페이스라 in-memory 구현으로 외부 의존 없이 syncer 단위 테스트 가능 (`test/data/syncer_test.dart` 참고).
