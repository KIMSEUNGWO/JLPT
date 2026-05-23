# 예문 기능 구현 계획

## 목표

JLPT GO의 모든 단어가 하나 이상의 일본어 예문과 한국어 해석을 가지도록 데이터, DB, Repository, Sync, UI를 확장한다. 예문은 단어 데이터에 문장 자체를 중복 저장하지 않고 별도 예문 데이터의 id를 참조한다. 학습 카드에서는 현재 디자인 톤을 유지하면서 카드 상세 영역의 한자 정보 바로 위에 예문과 예문 음성 듣기 기능을 표시한다.

## 현재 구조 요약

- 번들 데이터는 `assets/json/` 아래 `japanese_words.json`, `chinese_chars.json`, `dataVersion.json`로 관리된다.
- 앱 시작 시 `DataSyncService`가 번들 또는 로컬 캐시 JSON의 버전을 고르고, `WordSyncer`와 `ChineseCharSyncer`가 Drift DB에 동기화한다.
- 원격 업데이트는 `UpdateService`가 `dataVersion`, `chinese_chars`, `japanese_words`를 내려받아 검증한 뒤 캐시에 저장하고 DB에 반영한다.
- 단어 도메인 모델은 `lib/domain/word.dart`, Drift 테이블은 `lib/data/database/tables/words_table.dart`, DAO는 `lib/data/database/daos/word_dao.dart`, Repository는 `lib/data/repositories/word_repository.dart`에 있다.
- 학습 카드 UI는 `lib/widgets/study/card/widget_word_card.dart`가 기본 단어/히라가나/한국어/발음 버튼을 렌더링하고, 펼친 상세 영역은 `lib/widgets/study/card/widget_word_card_detail.dart`가 한자 정보를 보여준다.
- 음성 듣기는 `AudioWaveAnimation`과 `SpeakerTTS`가 이미 `ja-JP` TTS 기반으로 제공한다.
- Drift DB의 현재 `schemaVersion`은 3이다. Drift 테이블/DAO를 추가하면 `build_runner`로 `.g.dart`를 재생성해야 한다.

## 요구사항 해석

1. 모든 단어는 반드시 하나 이상의 예문을 가진다.
   - JSON 검증 단계에서 각 단어의 `exampleIds`가 비어 있지 않은지 확인한다.
   - 예문 JSON에 실제로 존재하는 id만 참조하도록 cross validation을 추가한다.
   - DB 차원에서는 단어 row에 JSON 배열 형태의 `exampleIds`를 저장하거나, 정규화된 join 테이블을 둔다. 앱 규모와 조회 패턴상 join 테이블이 더 명확하다.

2. 단어는 예문 문장 자체가 아니라 예문번호를 참조한다.
   - 예문 데이터는 `example_sentences.json`의 `examples[]`에 보관한다.
   - 단어 데이터는 `exampleIds: [100001, ...]`만 가진다.
   - DB도 `ExampleSentences`와 `WordExampleRefs`를 분리한다.

3. 예문 음성듣기를 지원한다.
   - 기존 `AudioWaveAnimation(word: ...)`에 예문 일본어 문장을 전달해 재사용한다.
   - 단어 발음용 `_speaker`와 예문 발음용 speaker는 충돌 방지를 위해 카드 상세 예문 위젯 내부에서 별도 `SpeakerTTS`를 소유하게 한다.

4. 현재 디자인 스타일을 유지한다.
   - 기존 `CustomContainer`, `Theme.of(context).colorScheme.secondary`, `bodyMedium/displaySmall` 텍스트 토큰을 사용한다.
   - 새 카드나 과한 장식은 추가하지 않고, 현재 상세 박스 안에 `예문` 섹션을 추가한다.

5. 위치는 카드 widget 안의 한자 표시 바로 위다.
   - `WordCardDetailWidget` 내부의 `Column`에서 `한자 정보` 섹션보다 먼저 `ExampleSentenceSection`을 렌더링한다.

## 권장 데이터 형식

새 파일: `assets/json/example_sentences.json`

```json
{
  "examples": [
    {
      "id": 100001,
      "sentence": "毎日仕事に行きます。",
      "translation": "매일 일하러 갑니다."
    }
  ]
}
```

기존 파일 변경: `assets/json/japanese_words.json`

```json
{
  "words": [
    {
      "id": 1,
      "level": "N5",
      "act": "N",
      "word": "仕事",
      "hiragana": "しごと",
      "korean": "일, 직업",
      "exampleIds": [100001]
    }
  ]
}
```

데이터 규칙:

- `examples[].id`는 전체 예문에서 유일해야 한다.
- `sentence`와 `translation`은 비어 있지 않은 문자열이어야 한다.
- `words[].exampleIds`는 비어 있지 않은 int 배열이어야 한다.
- 모든 `exampleIds`는 `example_sentences.json`에 존재해야 한다.
- 하나의 예문은 여러 단어가 참조할 수 있다. 예: 같은 문장이 여러 단어 학습에 유용한 경우.
- `dataVersion.json`의 버전은 예문 데이터 추가와 단어 스키마 변경을 포함해 올린다.

## Drift 스키마 설계

새 테이블: `lib/data/database/tables/example_sentences_table.dart`

- `id`: int primary key
- `sentence`: text
- `translation`: text

새 테이블: `lib/data/database/tables/word_example_refs_table.dart`

- `wordId`: int, `Words.id` foreign key
- `exampleId`: int, `ExampleSentences.id` foreign key
- primary key: `{wordId, exampleId}`

이 설계를 권장하는 이유:

- 단어가 예문 id를 참조한다는 요구사항을 DB 구조로 직접 표현한다.
- 예문을 여러 단어가 공유할 수 있다.
- 예문 문장을 단어 row마다 중복 저장하지 않는다.
- 특정 단어의 예문 조회가 명확하다.

마이그레이션:

- `AppDatabase.schemaVersion`을 4로 올린다.
- `onUpgrade`에 `if (from < 4)` 블록을 추가해 `exampleSentences`, `wordExampleRefs`를 생성한다.
- `@DriftDatabase(tables: [...])`에 두 테이블을 등록한다.
- 새 DAO를 `daos:` 목록에 등록한다.
- 변경 후 `dart run build_runner build --delete-conflicting-outputs`를 실행한다.

주의:

- 기존 설치 사용자는 v4 마이그레이션 뒤 예문 DB가 비어 있을 수 있다. 따라서 예문 syncer의 meta version이 없으면 부팅 sync에서 반드시 예문 데이터를 채워야 한다.
- foreign key를 쓰므로 `beforeOpen`의 `PRAGMA foreign_keys = ON`은 현재처럼 유지한다.

## Domain/Repository 설계

새 도메인: `lib/domain/example_sentence.dart`

```dart
class ExampleSentence {
  const ExampleSentence({
    required this.id,
    required this.sentence,
    required this.translation,
  });

  final int id;
  final String sentence;
  final String translation;
}
```

`Word` 변경:

- `List<int> exampleIds` 필드를 추가한다.
- `Word.fromJson`에서 `exampleIds`를 필수로 검증한다.
- `copyWith`와 `_sameContent` 비교에도 `exampleIds`를 포함한다.
- 기존 테스트 fixture에는 `exampleIds`를 추가해야 한다.

새 DAO: `lib/data/database/daos/example_sentence_dao.dart`

- `getAllExamples()`
- `getByWordId(int wordId)` 또는 join 기반 `getExamplesForWord(int wordId)`
- `upsertExamples(List<ExampleSentencesCompanion>)`
- `replaceRefsForWords(List<WordExampleRefsCompanion>)`
- `countExamples()`

새 Repository: `lib/data/repositories/example_sentence_repository.dart`

- `Future<List<ExampleSentence>> getByWordId(int wordId)`
- `Future<void> syncAll({required List<ExampleSentence> examples, required Map<int, List<int>> wordExampleRefs, required Version version})`
- `Future<int> countExamples()`
- `Future<Version?> currentVersion()`은 `AppMetaRepository`를 통해 조회한다.

트랜잭션 권장 순서:

1. `ExampleSentences` upsert
2. 해당 source 전체 기준으로 `WordExampleRefs` replace
3. `examples_version` meta commit

## Sync/Update 변경 계획

`AppMetaRepository`:

- `examples_version`
- `examples_synced_at`
- `getExamplesVersion()`
- `markExamplesSynced(Version v)`

새 Syncer: `lib/data/sync/example_sentence_syncer.dart`

- `dataKey: 'example_sentences'`
- `parse()`에서 `examples` 배열을 검증한다.
- id 중복은 거부한다. 같은 id에 같은 내용이라도 데이터 작성 오류를 빨리 찾기 위해 거부하는 편이 좋다.
- `expectedMinRowCount`는 실제 예문 수 확정 전까지 단어 수 이상을 기준으로 잡는다. 모든 단어가 하나 이상 예문을 가져야 하므로 최소 2150 이상이 자연스럽다.

단어 sync 검증 강화:

- `WordSyncer.parse()`는 `exampleIds`의 존재와 비어 있지 않음까지만 검증할 수 있다.
- 예문 id 존재 여부는 `DataSyncService` 또는 별도 validator에서 `words`와 `example_sentences`를 함께 읽은 뒤 검증해야 한다.
- 권장 방식은 `DataSyncService`가 단어와 예문 sync를 같은 source version에서 처리할 때, 먼저 raw JSON을 모두 parse하고 cross validation 후 persist하는 것이다.

`DataSyncService`:

- 생성자에 `ExampleSentenceSyncer`를 추가한다.
- `_syncFromPickedSource()`에서 examples도 up-to-date인지 확인한다.
- sync 순서는 `examples` -> `words` -> `wordExampleRefs`가 안전하다. 구현을 단순화하려면 `ExampleSentenceRepository.syncAll`이 예문과 refs를 함께 저장하고, 단어 sync는 기존처럼 단어만 저장한다.
- 캐시 fallback 로직도 examples 실패 시 번들로 돌아가야 한다.

`UpdateService`:

- 원격 fetch 대상에 `example_sentences` 추가.
- `applyUpdate()`에서 `rawExamples`를 함께 내려받는다.
- words, chars, examples를 모두 검증하고 cross validation을 통과한 뒤에만 cache write를 수행한다.
- cache write에 `example_sentences.json` 추가.
- DB persist에도 examples sync 추가.

`RemoteJsonDataSource` provider:

- `urlsByName`에 `example_sentences` 추가.
- `Constant.EXAMPLE_SENTENCES_LINK` 추가.

## Provider/UI 연결

`lib/data/providers.dart`:

- `exampleSentenceRepositoryProvider`
- `exampleSentenceSyncerProvider`
- `FutureProvider.autoDispose.family<List<ExampleSentence>, int>` 형태의 `exampleSentencesByWordProvider`

예:

```dart
final exampleSentencesByWordProvider =
    FutureProvider.autoDispose.family<List<ExampleSentence>, int>((ref, wordId) {
  return ref.read(exampleSentenceRepositoryProvider).getByWordId(wordId);
});
```

UI 새 위젯:

- 파일: `lib/widgets/study/card/widget_example_sentence.dart`
- 입력: `Word word`
- 내부에서 `ref.watch(exampleSentencesByWordProvider(word.id))`
- 로딩: `SizedBox.shrink()`
- 에러: 작은 텍스트 `예문을 불러올 수 없습니다.`
- 데이터 없음: 정상 데이터에서는 없어야 하지만 방어적으로 `예문 정보가 없습니다.`

권장 레이아웃:

- 섹션 제목: `예문`
- 일본어 문장: `bodyLarge` 또는 `displaySmall`보다 작은 크기, 현재 카드 상세 박스 안에서 줄바꿈 허용
- 해석: `bodyMedium`, `onSurface`
- 음성 버튼: `AudioWaveAnimation(word: example.sentence, title: '예문 듣기')`
- 예문이 여러 개면 세로로 나열하고 각 예문 사이에 `SizedBox(height: 12)` 또는 얇은 구분 여백을 둔다.

삽입 위치:

`WordCardDetailWidget`의 현재 구조는 한자 정보를 직접 렌더링한다. 다음 순서가 되도록 바꾼다.

1. `ExampleSentenceSection(word: word)`
2. `SizedBox(height: 16)`
3. 기존 `한자 정보` 제목
4. 기존 `ChineseCharWidget` 목록

한자 없는 단어도 예문은 보여야 하므로, 현재 `chars.isEmpty`일 때 전체 상세 위젯이 `한자 정보가 없습니다.`만 반환하는 구조를 바꿔야 한다. 예문 섹션은 한자 유무와 무관하게 먼저 렌더링하고, 한자 섹션만 조건부 메시지를 표시한다.

## 테스트 계획

데이터 파서 테스트:

- `ExampleSentence.fromJson` 정상/누락/빈 문자열/타입 오류
- `ExampleSentenceSyncer.parse` id 중복 오류
- `Word.fromJson`에서 `exampleIds` 누락, 빈 배열, int 아닌 값 오류
- 단어가 존재하지 않는 예문 id를 참조할 때 cross validation 오류
- 모든 단어가 하나 이상의 예문을 참조하는 fixture 검증

Repository/DAO 테스트:

- 인메모리 DB에서 예문 upsert 후 단어 id로 조회
- 같은 예문을 여러 단어가 참조할 수 있는지
- sync 재실행 시 기존 refs가 source 기준으로 교체되는지
- v3 -> v4 마이그레이션 후 새 테이블 생성 확인

UI 테스트:

- `WordCardDetailWidget`가 예문 섹션을 한자 정보보다 먼저 렌더링하는지
- 예문 일본어/해석이 표시되는지
- 예문 없는 비정상 상태에서 앱이 crash하지 않는지
- TTS는 `Speaker` test double을 주입할 수 있게 설계하면 음성 버튼 tap 테스트가 쉬워진다.

실행 명령:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

## 구현 순서

1. `assets/json/example_sentences.json` 샘플을 만들고 `japanese_words.json`에 `exampleIds`를 추가한다.
2. `ExampleSentence` 도메인과 `Word.exampleIds`를 추가한다.
3. Drift 테이블/DAO/DB 등록/마이그레이션 v4를 추가한다.
4. `build_runner`를 실행해 generated files를 갱신한다.
5. `ExampleSentenceRepository`와 provider를 추가한다.
6. `ExampleSentenceSyncer`와 `AppMetaRepository` 예문 버전 meta를 추가한다.
7. `DataSyncService`, `UpdateService`, `RemoteJsonDataSource`, `Constant`에 `example_sentences` 흐름을 연결한다.
8. 단어-예문 cross validation을 추가한다.
9. `WordCardDetailWidget`를 리팩터링해 예문 섹션을 한자 정보 위에 표시한다.
10. 테스트 fixture와 단위 테스트를 갱신한다.
11. `flutter analyze`, `flutter test`로 검증한다.

## 리스크와 결정 필요 사항

- 원격 저장소에 `example_sentences.json` URL을 추가해야 한다. 현재 URL 패턴상 `https://raw.githubusercontent.com/KIMSEUNGWO/JLPT/refs/heads/main/json/example_sentences.json` 형태가 예상되지만 실제 파일 생성 후 확정해야 한다.
- 전체 2150개 단어에 대한 예문 데이터를 한 번에 준비하지 못하면 요구사항 1번을 만족할 수 없다. 일부만 추가하는 feature flag 방식은 요구사항과 맞지 않는다.
- 단어 JSON 전체에 `exampleIds`를 넣는 작업은 데이터 작성량이 크므로, 앱 코드 구현과 별도 데이터 검수 체크가 필요하다.
- 단어 발음 자동 재생과 예문 발음 버튼을 같은 speaker로 공유하면 stop/completion handler가 충돌할 수 있다. 예문 위젯은 독립 speaker를 쓰는 설계가 안전하다.
- 카드 상세 영역의 높이가 늘어나므로 작은 화면에서는 `StudyPage`의 스크롤 가능 여부를 확인해야 한다. 현재 카드가 고정 높이처럼 동작한다면 `SingleChildScrollView` 또는 상세 영역 내부 스크롤 조정이 필요할 수 있다.
