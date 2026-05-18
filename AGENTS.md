# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## About

JLPT GO는 JLPT N1–N5 수준별 단어·문법 학습 Flutter 앱입니다. 플래시카드 학습, 4지선다 테스트, 발음 기능을 제공합니다.

## Commands

```bash
# 의존성 설치
flutter pub get

# Drift DAO/DB + Riverpod codegen 생성 (엔티티 변경 시 반드시 실행)
dart run build_runner build --delete-conflicting-outputs

# 개발 중 watch 모드
dart run build_runner watch --delete-conflicting-outputs

# 정적 분석
flutter analyze

# 테스트
flutter test
flutter test test/data/word_repository_test.dart  # 단일 파일

# 빌드
flutter build apk    # Android
flutter build ios    # iOS
```

> `@DriftDatabase`, `@DriftAccessor`, `@riverpod` 어노테이션이 붙은 파일을 수정하면 반드시 `build_runner`를 재실행하라. `.g.dart` 파일은 생성 산출물이며 직접 편집하지 않는다.

---

## Architecture

### 레이어 구조

```
lib/
├─ main.dart               # DB open + LocalStorage init → ProviderScope
├─ app/
│  ├─ app.dart             # MaterialApp.router (go_router)
│  ├─ router.dart          # 라우트 테이블 (appRouter)
│  └─ bootstrap.dart       # AppDatabase open 헬퍼
├─ core/
│  ├─ theme/               # AppTheme, AppColors (컬러 토큰)
│  ├─ constants.dart       # GROUP_SIZE, 원격 URL
│  └─ logger.dart          # appLogger (logger 패키지 래퍼)
├─ data/
│  ├─ database/
│  │  ├─ app_database.dart        # @DriftDatabase (tables + daos)
│  │  ├─ tables/                  # Words, ChineseChars, TestResults, TestQuestions
│  │  └─ daos/                    # WordDao, ChineseCharDao, TestResultDao
│  ├─ repositories/               # WordRepository, ChineseCharRepository, TestResultRepository
│  ├─ remote/                     # json_data_source.dart (GitHub JSON fetch)
│  ├─ local/                      # settings_repository.dart (LocalStorage 래퍼)
│  └─ providers.dart              # Riverpod 프로바이더 (appDatabaseProvider, wordRepositoryProvider …)
├─ domain/
│  ├─ entities/            # 순수 Dart 엔티티 (Word, ChineseChar, Question …)
│  ├─ enums/               # Level, Act, PracticeType
│  ├─ question/            # QuestionGenerator<T> 전략 패턴
│  └─ box/                 # QuestionEntityBox (테스트 결과 도메인 모델)
├─ notifier/               # @riverpod codegen Notifier들
│  ├─ today_notifier.dart  # todayProvider
│  ├─ timer_notifier.dart  # timerProvider
│  ├─ study_cycle_notifier.dart   # studyCycleProvider
│  └─ recently_view_notifier.dart # recentlyViewProvider
└─ widgets/ (features/)
   ├─ page_main.dart        # 홈 화면
   ├─ study/                # 학습 카드 + 학습 리스트
   ├─ study/test/           # 테스트 + 결과
   └─ component/            # 공용 위젯
```

### 핵심 원칙
- **위젯은 DB를 모른다.** 모든 데이터 접근은 Riverpod로 주입된 Repository를 통한다.
- **Repository는 UI를 모른다.** `WidgetRef`를 받지 않는다. notifier 호출은 위젯/notifier 쪽에서.
- **Domain 계층은 framework-free.** Drift/GoRouter import 금지.
- **Notifier는 `@riverpod` codegen.** 생성된 provider 이름 규칙: `TodayNotifier` → `todayProvider` (Notifier 접미사 제거).

---

## Drift 스키마

| 테이블 | 설명 |
|---|---|
| `Words` | 단어 (level, act, word, hiragana, korean, is_read, wrong_cnt) |
| `ChineseChars` | 한자 정보 (char PK, korean_char, sound_reading JSON, mean_reading JSON) |
| `TestResults` | 테스트 세션 (level?, type, taken_at, time_seconds) |
| `TestQuestions` | 세션별 문항 (question_word_id FK, my_answer_word_id?, examples_json, is_correct, reverse) |

DAOs는 `lib/data/database/daos/` 에, Repository는 `lib/data/repositories/` 에 위치한다.

---

## Riverpod 3 codegen 컨벤션

- 클래스에 `@riverpod` 어노테이션 → `part 'xxx.g.dart';` 필수
- `build()` 에서 초기 상태 반환 (LocalStorage는 `main()`에서 이미 초기화됨)
- 생성된 provider 이름: 클래스명 camelCase + `Notifier` 제거. 예: `TimerNotifier` → `timerProvider`
- `ref.read(xProvider.notifier).method()` 로 상태 변경

---

## go_router 라우트 테이블

| 경로 | 화면 | extra 타입 |
|---|---|---|
| `/` | InitWidget (초기화) | - |
| `/home` | MainPage | - |
| `/study/:level` | StudyListPage | `List<Word>` |
| `/study/:level/group` | StudyPage | `Map<String, dynamic>` |
| `/test` | TestPage | `Map<String, dynamic>` |
| `/test/results` | TestResultPage | `QuestionEntityBox?` |
| `/test/results/detail` | TestResultDetailPage | `QuestionEntityBox` |

`appRouter`는 `lib/app/router.dart`에 정의. `context.push('/경로', extra: data)` 사용.

---

## Initialization sequence

1. `main()` — Drift DB open + `LocalStorage.initInstance()` → `ProviderScope`
2. `InitWidget.initState()` — `MobileAds.instance.initialize()` (fire-and-forget)
3. `UpdateChecker._checkUpdates()` — bundled `dataVersion.json` vs GitHub 버전 비교
   - 최신이면 `InitJapanWordHelper` / `InitChineseCharHelper` 로 Drift upsert
   - 구버전이면 UpdateModal 표시 후 동일 흐름
4. `MainPage` 렌더 (notifier는 ref.watch 시 build()에서 자동 초기화)

---

## 새 기능 추가 체크리스트

1. **Entity** — `lib/domain/` 에 순수 Dart 클래스 추가
2. **Drift 테이블** — `lib/data/database/tables/` 에 Table class 추가 → `app_database.dart` 에 등록 → `build_runner build`
3. **DAO** — `lib/data/database/daos/` 에 `@DriftAccessor` 클래스 추가 → `app_database.dart` `daos:` 목록에 추가 → 재빌드
4. **Repository** — `lib/data/repositories/` 에 Repository 클래스 추가
5. **Provider** — `lib/data/providers.dart` 에 `Provider<XRepository>` 추가
6. **Notifier** (상태 필요 시) — `lib/notifier/` 에 `@riverpod` Notifier 추가 → `build_runner build`
7. **Route** — `lib/app/router.dart` 에 GoRoute 추가
8. **Widget** — `lib/widgets/` 에 `ConsumerWidget` / `ConsumerStatefulWidget` 작성

---

## 테스트

```
test/
├─ widget_test.dart                  # LocalStorage 유틸 smoke test
├─ data/word_repository_test.dart    # Drift in-memory DB 사용 Repository 단위 테스트
└─ domain/question_creator_test.dart # QuestionCreator 4지선다 생성 로직 단위 테스트
```

Repository 테스트는 `AppDatabase.forTesting(NativeDatabase.memory())` 으로 인메모리 DB를 사용.
