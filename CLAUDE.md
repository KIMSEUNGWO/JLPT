# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

JLPT GO는 수준별 단어 학습 Flutter 앱입니다. 플래시카드 학습, 4지선다 테스트, TTS 발음 기능을 제공합니다. Drift + Riverpod 3 기반.

단어 암기 기능 자체는 언어 중립적이며, 언어별 차이는 **"코스(Course)" 추상**으로 외부화돼 있습니다 (`lib/domain/course/`). 현재는 **JLPT 일본어 단일 코스**만 노출하지만, 영어(CEFR)·중국어(HSK) 등은 [Course] config + 데이터 파일만 추가하면 확장됩니다. 코스 선택 UI 는 아직 없습니다 (`activeCourseProvider` 가 단일 진입점).

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
- **언어 종속은 Course 로 외부화.** 위젯/도메인/데이터에 일본어·JLPT 를 하드코딩하지 않는다.

### 코스(Course) 추상 (`lib/domain/course/`)

- `Course` — 한 학습 트랙의 정적 정의: `id`(예: `'jlpt_ja'`), `displayName`(예: `'JLPT'`), `ttsLocale`, `readingLabel`(없으면 null), `hasCharacterModule`/`characterModuleLabel`, 정렬된 `levels`, `data`(JSON 키 + 검증 임계치).
- `Level` — **enum 이 아니라** 코스가 정의하는 immutable 값 객체 (`code`/`label`/`order`). 동등성은 `code` 기준 → `Map<Level,_>` 키로 사용. DB·스토리지·라우트엔 `code` 만 저장.
- `CourseRegistry` — 코드 레지스트리. `defaultCourse`/`byId`. `activeCourseProvider`(`providers.dart`) 가 활성 코스를 반환 — 지금은 상수, 코스 선택 UI 추가 시 여기만 교체.
- 도메인 일반화: `Word.reading`(nullable, 옛 `hiragana`)·`Word.meaning`(옛 `korean`)·`Word.levelCode`. `QuestionBox.getTerm()/getMeaning()`. `StudyOptions.showReading/showMeaning`. (`fromJson` 은 옛 키 `hiragana`/`korean`/`showHiragana`/`showKorean` 를 폴백으로 읽어 데이터 호환)

---

## Drift 스키마 (schemaVersion = 5)

| 테이블 | 설명 |
|---|---|
| `Words` | 단어 (id PK, **course**, level, act, word, hiragana, korean, is_read, wrong_cnt) |
| `ChineseChars` | 문자/한자 (char PK, **course**, korean_char, sound_reading JSON, mean_reading JSON) |
| `ExampleSentences` | 예문 (id PK, **course**, sentence, translation) |
| `WordExampleRefs` | 단어↔예문 (word_id, example_id FK, **course**) |
| `TestResults` | 테스트 세션 (id, **course**, level?, type, taken_at, time_seconds) |
| `TestQuestions` | 세션별 문항 (question_word_id FK, my_answer_word_id?, examples_json, is_correct, reverse) |
| `DailyStats` | 일별 통계 (date PK) — **코스 횡단 전역** (의도적, course 컬럼 없음) |
| `AppMeta` | 앱 메타 key-value. 엔티티 버전 키는 코스 네임스페이스: `words_version:<courseId>`, `chars_version:<courseId>`, `*_synced_at:<courseId>`. 전역 키: `last_sync_error`, `best_streak`, `daily_stats_backfilled_v3` |

- **물리 컬럼명 `hiragana`/`korean` 은 유지**하고 repo(`WordRepository`)가 도메인의 `reading`/`meaning` 으로 매핑한다 (컬럼 rename = 테이블 재생성 비용 회피).
- **course 컬럼**: 콘텐츠/진행/테스트 테이블의 다국어 차원. 기본값 `'jlpt_ja'`. (단일 코스라 PK 는 아직 단일; 2번째 코스 추가 시 복합 PK 마이그레이션 예정)

Migration `onUpgrade`: `<2` appMeta 신설 / `<3` dailyStats / `<4` exampleSentences+wordExampleRefs / `<5` 각 테이블 `course` 컬럼 추가(`_addCourseColumnIfMissing` — 이미 course 있는/없는 테이블 방어) + 메타 키를 `:jlpt_ja` 네임스페이스로 이전(`_migrateMetaKeysToCourse`). 기존 row 는 `'jlpt_ja'` 로 태깅.

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

> 실제 syncer 는 `courseId`/`dataKey`/`expectedMinRowCount` 를 활성 코스에서 주입받고
> (`providers.dart`), 메타 버전 조회/commit 도 `courseId` 를 받는다
> (예: `meta.getWordsVersion(courseId)`, `meta.markWordsSynced(v, courseId)`).
> `DataSyncService`·`UpdateService` 는 하드코딩된 3종이 아니라 `courseSyncersProvider`
> 가 만든 **syncer 리스트를 순회**한다 (문자 모듈 없는 코스는 char syncer 제외).

### 새 코스(언어) 추가

1. `lib/domain/course/course_registry.dart` 에 `Course` 인스턴스 정의 (levels, ttsLocale, readingLabel, hasCharacterModule, data 키/URL/임계치) → `CourseRegistry.all` 에 등록.
2. 데이터 파일 추가 (`assets/json/<words>.json`, `<examples>.json`, 필요 시 문자 모듈 JSON) + `dataVersion`. 단어 JSON 은 `level`/`act`/`word`/`reading`(또는 `hiragana`)/`meaning`(또는 `korean`)/`exampleIds` 형식.
3. (다중 코스 동시 노출 시) DB 복합 PK 마이그레이션 + 코스 선택 UI + `activeCourseProvider` 를 설정에서 읽도록 교체.

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
