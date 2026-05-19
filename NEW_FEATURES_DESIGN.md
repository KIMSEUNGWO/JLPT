# 신규 기능 설계 — 학습 옵션 토글 / 통계 강화

현재 코드베이스(StartupGate · Drift v2 · Riverpod 3 codegen) 위에 두 기능을 더한다. 구현 순서는 **Feature 1 → Feature 2** 고정 — Feature 1은 스키마 변경 없이 학습 경험을 바로 개선하고, Feature 2는 v3 migration·이중 source·backfill 까지 포함되어 작업면이 넓다.

| | Feature 1 | Feature 2 |
|---|---|---|
| 이름 | 학습 옵션 토글 (StudyOptions) | 통계 강화 (StatsHub) |
| 목적 | 자동 발음 / 히라가나 / 한국어 노출 토글을 카드 간 유지 | 단순 "오늘의 학습" 을 일·주·스트릭·달성률 통계로 확장 |
| 영향 범위 | `WordCardWidget`, `StudyPage`, `LocalStorage`, `SpeakerTTS` | 새 Drift 테이블, `TodayNotifier` 외 wiring, `MainPage` |
| 스키마 | 변경 없음 (SharedPreferences) | v2 → v3 (`DailyStats` 신설) |
| 추정 | 0.5 ~ 1일 | 2 ~ 3일 (UI 별도 PR 포함 시 +1일) |

---

## Feature 1. 학습 옵션 토글 (StudyOptions)

### 1-1. 동작

`StudyPage` 카드 위에 토글 3개를 둔다. 상태는 **앱 재시작 후에도 유지**, 카드를 next 했을 때 **이전 카드 상태가 그대로 적용**된다.

| 토글 | ON 동작 | OFF 동작 |
|---|---|---|
| 🔊 자동 발음 | 새 카드 첫 프레임 + 200ms 뒤 TTS 자동 재생 | 탭으로만 재생 |
| あ 히라가나 | 히라가나 표시 | 빈 자리 |
| 한 한국어 | 한국어 뜻 표시 | 빈 자리 |

원칙: **현재 카드에서 토글 ON 으로 바꿔도 자동 발음은 트리거되지 않는다** (예상치 못한 발화 방지). 다음 카드부터 적용.

### 1-2. 데이터 모델

`lib/domain/study_options.dart` — immutable + `copyWith` + `toJson/fromJson`.

```dart
class StudyOptions {
  const StudyOptions({
    this.autoPlayPronunciation = false,
    this.showHiragana = false,
    this.showKorean = false,
  });
  final bool autoPlayPronunciation;
  final bool showHiragana;
  final bool showKorean;
  StudyOptions copyWith({...});
  Map<String, dynamic> toJson();
  factory StudyOptions.fromJson(Map<String, dynamic> json);
}
```

단일 JSON 으로 저장하면 옵션 추가가 안전하고 read/write 가 묶여 race 가 없다.

### 1-3. 저장소

`lib/component/local_storage.dart` 에 `STUDY_OPTIONS` 키 추가. `StorageKey` enum 통일.

```dart
StudyOptions getStudyOptions() {
  final raw = _storage.getString(_kStudyOptions);
  if (raw == null) return const StudyOptions();
  try { return StudyOptions.fromJson(jsonDecode(raw)); }
  catch (_) { return const StudyOptions(); }   // 손상된 JSON → 기본값
}
Future<void> saveStudyOptions(StudyOptions opts) =>
    _storage.setString(_kStudyOptions, jsonEncode(opts.toJson()));
```

### 1-4. Notifier

```dart
@Riverpod(keepAlive: true)
class StudyOptionsNotifier extends _$StudyOptionsNotifier {
  @override
  StudyOptions build() => LocalStorage.instance.getStudyOptions();

  void toggleAutoPlay() => _update(state.copyWith(autoPlayPronunciation: !state.autoPlayPronunciation));
  void toggleHiragana() => _update(state.copyWith(showHiragana: !state.showHiragana));
  void toggleKorean()   => _update(state.copyWith(showKorean: !state.showKorean));

  void _update(StudyOptions next) {
    state = next;
    unawaited(LocalStorage.instance.saveStudyOptions(next));
  }
}
```

`keepAlive: true` — 옵션은 앱 전역 단일 인스턴스로 공유.

### 1-5. 발음 책임 통합 (★ Feature 1 전제 조건)

현재 발음 버튼은 `AudioWaveAnimation` 내부에서 `final Speaker _speaker = SpeakerTTS();` 로 자체 인스턴스를 생성한다. 자동 발음용 speaker 를 따로 두면 `stop()` 이 서로 영향을 주지 않아 음성이 겹친다.

**선행 작업** (Feature 1 본 구현 전에 끝낸다):

1. `WordCardWidget` 이 단일 `Speaker` 를 보유하고, 발음 버튼(`AudioWaveAnimation`)·자동 발음 모두 같은 인스턴스를 쓰도록 리팩토링.
2. `AudioWaveAnimation` 은 생성자로 `Speaker` 를 받는다 (테스트 hook 도 겸함). `dispose()` 에서 `_speaker.stopped()` 호출 보장.
3. `SpeakerTTS` 에 `_initialized` 플래그 도입 — init 완료 전 `speak/stop` 호출은 await 후 진행:

```dart
class SpeakerTTS extends Speaker {
  late final FlutterTts flutterTts;
  Future<void>? _initFuture;

  @override
  Future<void> init({Function()? completionHandler}) {
    return _initFuture ??= _doInit(completionHandler);
  }
  Future<void> _doInit(Function()? completionHandler) async { ... }

  @override
  Future<void> speak(String word) async {
    await _initFuture;            // init 보장
    await flutterTts.stop();
    await flutterTts.speak(word);
  }
  @override
  Future<void> stopped() async {
    if (_initFuture == null) return;
    await _initFuture;
    await flutterTts.stop();
  }
}
```

### 1-6. WordCardWidget 리팩토링

기존 자체 `_toggleHiragana`/`_toggleKorean` 제거. 전역 옵션 watch.

```dart
class WordCardWidget extends ConsumerStatefulWidget {
  const WordCardWidget({super.key, required this.word, this.speaker});
  final Word word;
  final Speaker? speaker;                            // 테스트 hook — production 은 null
}

class _WordCardWidgetState extends ConsumerState<WordCardWidget> {
  late final Speaker _speaker;
  late final int _capturedWordId;                    // 비동기 콜백 안전

  @override
  void initState() {
    super.initState();
    _capturedWordId = widget.word.id;
    _speaker = widget.speaker ?? SpeakerTTS();
    unawaited(_speaker.init());
    final opts = ref.read(studyOptionsNotifierProvider);   // 1회 캡처
    if (opts.autoPlayPronunciation) _scheduleAutoPlay();
  }

  void _scheduleAutoPlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted || widget.word.id != _capturedWordId) return;
      await _speaker.speak(widget.word.word);
    });
  }

  @override
  Widget build(BuildContext context) {
    final opts = ref.watch(studyOptionsNotifierProvider);   // hiragana/korean 만 반응
    return /* opts.showHiragana / opts.showKorean 분기 */;
  }

  @override
  void dispose() {
    unawaited(_speaker.stopped());   // dispose 는 await 불가 → fire-and-forget
    super.dispose();
  }
}
```

**핵심 디테일**:
- `autoPlayPronunciation` 은 `ref.read` 로 initState 시점 1회만 캡처. `showHiragana/Korean` 은 `ref.watch` 로 실시간 반응.
- 자동 발음 delay 중 카드 인스턴스가 같은 State 로 유지되며 `word` 만 바뀌는 경우까지 막기 위해 `_capturedWordId` 와 비교.
- `dispose()` 의 `unawaited(_speaker.stopped())` 는 `SpeakerTTS._initFuture` null-guard 가 있어야만 안전. init 전/중/후 모두 안전한 `stopped()` 는 1-5 의 전제.
- 테스트에서는 mock `Speaker` 를 widget 생성자로 직접 주입 → `verify(mock.speak(...))` 로 호출 검증.

### 1-7. StudyPage — 카드 key 변경

현재 `WordCardWidget(key: ValueKey<int>(_currentIndex), ...)` 은 `_innerWords` 가 재셔플돼 `_currentIndex` 가 0 으로 돌아오면 같은 key 로 인식되어 카드가 재생성되지 않을 수 있다. 자동 발음은 initState 시점에 묶이므로 **카드 인스턴스 재생성이 보장돼야** 한다.

```dart
WordCardWidget(
  key: ValueKey<String>(
    '${widget.args.level.name}-${word.id}-$_currentIndex-$_round',
  ),
  word: word,
)
```

복합 key 가 디버깅에 유리. `_round` 는 `_pickUnread()` 가 호출되어 `_innerWords` 가 새로 만들어질 때마다 1 증가 — 같은 word 가 다음 라운드에 다시 나와도 새 인스턴스가 보장된다.

### 1-8. UI — 토글 바

카드 위에 항상 노출 (BottomSheet 보다 학습 흐름 중 즉시 토글 우선).

```
[ あ히라가나 ●OFF ] [ 한국어 ●ON ] [ 🔊자동발음 ●ON ]
┌──── WordCardWidget ────┐
│   受け取る              │
│   うけとる              │  ← showHiragana ON
│   받다                  │  ← showKorean ON
│   🔊 발음 듣기           │
└────────────────────────┘
```

모바일 폭에서 3개 토글이 눌리도록 icon + 짧은 label.

### 1-9. 테스트

- `StudyOptions.toJson/fromJson` round-trip
- `StudyOptionsNotifier.toggle*` 후 상태 변경 + LocalStorage 저장
- `WordCardWidget` 위젯 테스트 — `ProviderScope(overrides: [studyOptionsNotifierProvider.overrideWith(...)])` + mock `Speaker` factory 주입, `speak()` 호출 검증
- `SpeakerTTS` init 전 `speak/stop` 호출이 안전한지 (mock FlutterTts 로 단위 테스트)

### 1-10. 작업 순서

1. `StudyOptions` domain + `LocalStorage` + `StorageKey.STUDY_OPTIONS`
2. `SpeakerTTS` lifecycle 보강 (`_initFuture`)
3. `AudioWaveAnimation` 에 `Speaker` 주입 가능하도록 변경
4. `StudyOptionsNotifier` + `build_runner`
5. `WordCardWidget` 을 `ConsumerStatefulWidget` 으로 변경 — 단일 Speaker 보유
6. `StudyPage` 카드 key 를 `ValueKey('${round}-${id}')` 로 교체
7. 토글 바 위젯 추가
8. 테스트

---

## Feature 2. 통계 강화 (StatsHub)

### 2-1. 동작

홈 "오늘의 학습" 박스를 확장. 단, **Phase B 에서는 기존 두 수치(시간/단어)를 그대로 두고 그 아래에 주간 막대 + 스트릭만 덧붙인다**. 박스 전체 교체는 Phase C 별도 PR.

```
┌─ 오늘의 학습 ──────────────────────────────┐
│  ⏱ 2.3시간       📚 87단어                │  ← 기존 그대로 (TodayData)
│  ─────────────────────────────────────── │
│  🔥 7일 연속 · 최고 12일                  │  ← Phase B 추가 (DailyStats)
│  주간 ▮▮▮▮▯▮▮                            │  ← Phase B 추가
│   월 화 수 목 금 토 일                    │
└────────────────────────────────────────────┘
[ 자세히 보기 ▶ ]   ← Phase C
```

### 2-2. Drift v3 — DailyStats

하루 = 한 row. `date` 는 `YYYYMMDD` int (`LocalStorage.dateToInt` 와 동일).

```dart
@DataClassName('DailyStatData')
class DailyStats extends Table {
  IntColumn get date => integer()();
  IntColumn get studySeconds   => integer().withDefault(const Constant(0))();
  IntColumn get wordsLearned   => integer().withDefault(const Constant(0))();
  IntColumn get grammarsLearned=> integer().withDefault(const Constant(0))();
  IntColumn get testsTaken     => integer().withDefault(const Constant(0))();
  IntColumn get correctAnswers => integer().withDefault(const Constant(0))();
  IntColumn get totalAnswers   => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}
```

Migration:

```dart
@override int get schemaVersion => 3;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {
    if (from < 2) await m.createTable(appMeta);
    if (from < 3) await m.createTable(dailyStats);
  },
  beforeOpen: (d) async => customStatement('PRAGMA foreign_keys = ON'),
);
```

### 2-3. DAO — 원자적 UPSERT

```dart
@DriftAccessor(tables: [DailyStats])
class DailyStatDao extends DatabaseAccessor<AppDatabase> with _$DailyStatDaoMixin {
  Future<DailyStatData?> getByDate(int date);
  Future<List<DailyStatData>> getRange(int from, int to);

  Future<void> increment({
    required int date,
    int seconds = 0, int words = 0, int grammars = 0,
    int testsTaken = 0, int correct = 0, int total = 0,
  }) async {
    await customStatement('''
      INSERT INTO daily_stats(date, study_seconds, words_learned, grammars_learned,
                              tests_taken, correct_answers, total_answers)
      VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)
      ON CONFLICT(date) DO UPDATE SET
        study_seconds   = study_seconds   + ?2,
        words_learned   = words_learned   + ?3,
        grammars_learned= grammars_learned+ ?4,
        tests_taken     = tests_taken     + ?5,
        correct_answers = correct_answers + ?6,
        total_answers   = total_answers   + ?7
    ''', [date, seconds, words, grammars, testsTaken, correct, total]);
  }
}
```

### 2-4. Repository

`DailyStatsRepository`:
- `recordSeconds(int)` / `recordWord()` / `recordTest({correct, total})` — 도메인 메서드
- `getThisWeek()` — `DateTime.now().subtract(Duration(days: 6))` → `dateToInt()` 변환 후 range. **int 산술 금지** (월말/연말 깨짐).
- `getStreak()` — 최근 30일 fetch 후 메모리에서 거꾸로 카운트 (`studySeconds > 0 || wordsLearned > 0`).
- `getBestStreak()` — `AppMeta` 에 캐시. `recordWord/recordSeconds` 시 current streak 재계산 → best 갱신.

### 2-5. Wiring — Transaction 경계 + Use-case 계층 (★)

**원칙 1**: 같은 의미 단위는 같은 transaction 안에서 처리. UI 갱신 hook 만 fire-and-forget.

**원칙 2**: `TodayNotifier` / `TimerNotifier` 에 DB repository 를 직접 섞지 않는다. 두 곳 갱신은 use-case 계층(`StudySession`)에서 묶는다 — notifier 책임이 비대해지는 것을 막고, 기존 `TodayNotifier` 의 단순 LocalStorage 동기 build 를 유지한다.

| 호출부 (use-case) | UI state 갱신 | stats 갱신 방식 |
|---|---|---|
| `StudySession.markWordRead` | `todayProvider.plusWordCnt()` | fire-and-forget — `DailyStatsRepository.recordWord()` |
| `StudySession.recordSeconds` | `timerProvider.setTimer()` | fire-and-forget — `DailyStatsRepository.recordSeconds()` |
| `TestResultRepository.save` | — | **같은 transaction 내부에서** `DailyStatDao.increment` 호출 |

```dart
// StudySession.markWordRead — 기존 메서드에 stats hook 만 추가
Future<void> markWordRead(int wordId) async {
  await ref.read(wordRepositoryProvider).markRead(wordId);
  ref.read(todayProvider.notifier).plusWordCnt();
  _recordStats(words: 1);
}

void _recordStats({int seconds = 0, int words = 0}) {
  unawaited(
    ref.read(dailyStatsRepositoryProvider).record(seconds: seconds, words: words).then((_) {
      ref.invalidate(weeklyStatsProvider);            // write 완료 후 invalidate
      ref.invalidate(studyStreakProvider);
    }).catchError((e, st) => appLogger.w('stats write failed', error: e, stackTrace: st)),
  );
}
```

```dart
// TestResultRepository.save — transaction 내부에서 stats 까지
await _db.transaction(() async {
  await _resultDao.insert(...);
  await _questionDao.insertAll(...);
  await _dailyStatDao.increment(
    date: LocalStorage.dateToInt(DateTime.now()),
    testsTaken: 1, correct: correctCount, total: totalCount,
  );
});
```

fire-and-forget 실패 시 로그 남김 — silent loss 방지.

### 2-6. Backfill — 1회성 marker

v3 첫 부팅 시 SharedPreferences 의 오늘치 hours/wordCnt 를 오늘 `DailyStats` 로 옮긴다. **재부팅마다 중복 누적되면 안 되므로** `AppMeta` 에 marker.

```dart
Future<void> bootstrapFromLocalStorage() async {
  const key = 'daily_stats_backfilled_v3';
  if (await _meta.has(key)) return;
  final today = LocalStorage.dateToInt(DateTime.now());
  final td = LocalStorage.instance.getTodayData();
  await _dao.increment(date: today, seconds: td.totalSeconds, words: td.wordCnt);
  await _meta.set(key, '1');
}
```

`DataSyncService.ensureSynced()` 끝에서 1회 호출.

### 2-7. Provider

```dart
@riverpod
Future<List<DailyStatData>> weeklyStats(WeeklyStatsRef ref) =>
    ref.watch(dailyStatsRepositoryProvider).getThisWeek();

@riverpod
Future<({int current, int best})> studyStreak(StudyStreakRef ref) async {
  final repo = ref.watch(dailyStatsRepositoryProvider);
  return (current: await repo.getStreak(), best: await repo.getBestStreak());
}
```

autoDispose — 홈 화면이 watch 할 때만 살아있음.

### 2-8. UI — Phase B 범위

- 기존 "오늘의 학습" 박스에 스트릭 줄 + 7개 막대 추가.
- 막대는 **`Container + Row`** 로 직접 — fl_chart 도입 보류.
  - 오늘 막대: primary color
  - 나머지: 학습량에 비례한 height + muted color, 0 인 날은 1px 회색 baseline
- 별도 `/stats` 페이지, 캘린더 히트맵, 도넛/라인 차트, 일 목표 설정 UI 는 **Phase C 별도 PR**.

### 2-9. 게임화 (Phase C+ 적용)

| 요소 | 원리 | 구현 시점 |
|---|---|---|
| 스트릭 🔥 | Loss aversion | Phase B |
| 주간 막대 | 일관성 시각화 | Phase B |
| 목표 달성률 | Goal gradient | Phase C (기본 20, 사용자 설정 옵션) |
| 최고 기록 토스트 | Self-competition | Phase C |
| 캘린더 히트맵 | Variable reward | Phase C |
| 알림 | 스트릭 끊김 방지 | 별도 PR (`flutter_local_notifications` + iOS/Android 권한) |

### 2-10. 최적화

- **읽기 캐시**: `weeklyStatsProvider` autoDispose FutureProvider. `recordWord/Seconds` 후 명시적 `invalidate` 로 갱신.
- **쓰기 batching**: 학습 종료 시점에 누적치 1회 (현재 흐름 유지). 매 초 호출되지 않음.
- **인덱스**: `DailyStats.date` PK → range query 도 PK 인덱스 사용.
- **스트릭 계산**: 최근 30일만 fetch. 1년 이상 이용자도 30 row 이상 stream 안 됨.

### 2-11. 테스트

- `DailyStatDao.increment` UPSERT 정확성 (두 번 호출 누적)
- `getStreak` — 오늘 시작 / 오늘 안 함 / 중간 빈 날 / 어제까지만 케이스
- `getThisWeek` — 빈 날 0 으로 채워 반환
- `TestResultRepository.save` 가 같은 transaction 에서 stats 갱신 (DB 검증)
- `bootstrapFromLocalStorage` idempotent (두 번 호출 시 중복 누적 없음)
- Migration v2 → v3 dry-run — **임시 디렉터리에 실제 파일 DB** 로 v2 schema 생성 후 v3 로 다시 open. in-memory 최신 schema 만 테스트하면 onUpgrade 분기를 검증 못 함. 기존 `Words/ChineseChars/AppMeta` row 보존 + `daily_stats` 생성 확인

### 2-12. 작업 순서

**Phase B — 데이터 + 최소 홈 UI**
1. `DailyStats` 테이블 + DAO + Repository
2. schemaVersion 3 + migration
3. `TestResultRepository.save` transaction 내부 stats 갱신
4. `TodayNotifier` / `TimerNotifier` fire-and-forget hook + invalidate
5. `bootstrapFromLocalStorage` + marker
6. `weeklyStatsProvider`, `studyStreakProvider`
7. 홈 박스에 스트릭 줄 + Container 막대 추가
8. 단위/통합 테스트, migration dry-run

**Phase C — 별도 PR**
- `/stats` 라우트 + 캘린더 히트맵
- 일 목표 설정 UI
- fl_chart 검토 (도넛/라인)
- 최고 기록 토스트

**별도 PR**
- `flutter_local_notifications` 기반 스트릭 알림

---

## 공통 영향도

| 영역 | 영향 |
|---|---|
| `pubspec.yaml` | Feature 1 변경 없음. Phase C 에서 fl_chart 검토 |
| Drift | v2 → v3 (Phase B) |
| Riverpod | `StudyOptionsNotifier`, `weeklyStatsProvider`, `studyStreakProvider` 추가 |
| 신규 라우트 | `/stats` (Phase C) |
| 신규 위젯 | 토글 바, 주간 막대, (Phase C) StatsPage |

## 위험 / 트레이드오프

- **자동 발음 + 빠른 카드 전환**: `_speaker.stopped()` 가 dispose 에서 호출되지만, 200ms delay 중 새 카드가 init 되면 이전 speaker 의 stop 과 새 speaker 의 speak 가 경합. `_capturedWordId` 체크와 `SpeakerTTS._initFuture` await 가 1차 방어. 음성 겹침이 관측되면 단일 글로벌 Speaker 로 한 단계 더 통합 검토.
- **DailyStats vs TodayData 이중 source (Phase B 기간 한정)**: 홈 표시 숫자는 `TodayData` 유지, 신규 통계만 `DailyStats`. Phase D 에서 `TodayData` 를 `DailyStats` 로 흡수 (별도 마이그레이션).
- **목표 단어 수 기본값 20**: Phase B 는 고정. 사용자 피드백 보고 Phase C 에서 설정화.
- **알림 권한 거부 fallback 없음**: 그래서 알림은 별도 PR 로 분리.

---

## Review History

- **Round 1 (이전)**: SpeakerTTS lifecycle, 카드 key 안정성, DailyStats transaction 경계, backfill marker, int 날짜 산술 금지, migration dry-run — 본문에 흡수.
- **Round 2 (현재)**: 본문은 구현 가능 수준. 아래 항목을 본문에 반영 완료.
  - `WordCardWidget` 생성자 → `Speaker? speaker` (mock 호출 검증 용이) — 1-6
  - 카드 key → `'${level}-${id}-${index}-${round}'` 복합 — 1-7
  - `TodayNotifier` 에 DB 섞지 않고 `StudySession` 에서 두 곳 갱신 — 2-5
  - Migration test → 임시 디렉터리 파일 DB — 2-11
  - `AudioWaveAnimation.dispose()` 의 `unawaited(_speaker.stopped())` 는 `SpeakerTTS._initFuture` null-guard 가 전제임을 명시 — 1-6

PR 범위 규칙:
- Feature 1 PR = StudyOptions + SpeakerTTS lifecycle + AudioWaveAnimation 주입 + WordCardWidget + 토글 바. **그 이상 금지** (속도/자동 넘김/BottomSheet 등은 후속).
- Feature 2 PR = Phase B 범위만 (DailyStats 저장/조회 + 홈 스트릭 줄 + 7개 막대). StatsPage / 캘린더 / fl_chart / 알림 / 일 목표 설정 UI 는 후속 PR.

---

## Implementation Log

(구현 시작 후 채움)
