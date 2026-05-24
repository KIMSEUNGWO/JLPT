# assets/json 단어 추가 Agent 명령어

> 이 파일들은 **JLPT 일본어 코스(`jlpt_ja`)** 의 데이터다. JSON 키 `hiragana`/`korean` 은
> 도메인의 일반화된 `reading`/`meaning` 필드로 매핑된다 (`Word.fromJson` 이 두 키를 폴백으로 읽음).
> 다른 코스(영어·중국어 등)를 추가할 때는 해당 코스의 데이터 파일을 별도로 만들고
> `lib/domain/course/course_registry.dart` 에 `Course` 를 등록한다.

아래 명령어에서 `<INPUT_JSON_PATH>`만 실제 추가할 단어 JSON 파일 경로로 바꿔서 실행한다.

```text
/agent <INPUT_JSON_PATH> 파일의 words 데이터를 assets/json/japanese_words.json에 병합해줘.

작업 규칙:

1. 입력 JSON 형식은 다음과 같다.
   {
     "words": [
       {
         "id": 1,
         "level": "N5",
         "act": "N",
         "word": "仕事",
         "hiragana": "しごと",
         "korean": "일, 직업",
         "exampleIds": []
       }
     ]
   }

2. assets/json/japanese_words.json에 단어를 merge한다.
   - 기존 데이터를 우선한다.
   - 중복된 표현은 추가하지 않는다.
   - 중복 여부는 word, hiragana, korean, level을 기준으로 확인한다.
   - 같은 표현이 이미 있으면 새 항목을 만들지 말고 기존 항목을 유지한다.
   - 새 단어 id는 japanese_words.json의 마지막 id 이후로 연속 부여한다.
   - 새 단어의 exampleIds에는 새로 추가한 예문 id를 연결한다.

3. assets/json/example_sentences.json에 예문을 추가한다.
   - 데이터가 많으면 반드시 50개 단어씩 청크를 나누어 작업한다.
   - 빠르게 끝내는 것보다 오래 걸리더라도 예문 하나하나의 품질에 집중한다.
   - 각 단어의 JLPT level에 맞는 어휘와 문법을 사용한다.
   - N5/N4 단어에는 너무 어려운 한자, 문형, 관용 표현을 피한다.
   - 예문에는 가능하면 대상 단어가 실제 형태 그대로 포함되게 한다.
   - 한국어 번역은 자연스럽고 학습자가 이해하기 쉽게 작성한다.
   - 한 단어에 2개 이상의 예문을 사용한다면 예문들은 완전히 다른 내용이어야 한다.
   - 기존 예문과 거의 같은 상황이나 문장 구조를 반복하지 않는다.
   - 새 예문 id는 example_sentences.json의 마지막 id 이후로 연속 부여한다.

4. assets/json/chinese_chars.json에 누락 한자를 추가한다.
   - 새 단어와 새 예문에 포함된 모든 한자를 확인한다.
   - chinese_chars.json에 이미 있는 char는 중복 추가하지 않는다.
   - 누락된 한자만 chars 배열에 추가한다.
   - 형식은 다음과 같이 맞춘다.
     {
       "char": "仕",
       "soundReading": ["し"],
       "meanReading": ["つかえる"],
       "koreanChar": "仕 (섬길 사)"
     }
   - soundReading은 음독, meanReading은 훈독을 히라가나로 작성한다.
   - 읽기가 없으면 빈 배열 []을 사용한다.
   - koreanChar는 "한자 (뜻 음)" 형식을 따른다.

5. 마지막으로 assets/json/dataVersion.json을 갱신한다.
   - version은 현재 버전의 patch 버전을 1 올린다.
   - description에는 이번 변경을 요약한 commit message를 적는다.
   - last_updated에는 오늘 날짜를 YYYY-MM-DD 형식으로 적는다.

6. 최종 검수까지 완료한다.
   - japanese_words.json에 중복 단어가 없는지 확인한다.
   - word id와 example id가 기존 id와 충돌하지 않는지 확인한다.
   - 모든 새 단어의 exampleIds가 실제 example id를 가리키는지 확인한다.
   - 새 단어와 새 예문에 포함된 한자가 chinese_chars.json에 모두 있는지 확인한다.
   - chinese_chars.json에 같은 char가 중복되지 않았는지 확인한다.
   - japanese_words.json, example_sentences.json, chinese_chars.json, dataVersion.json이 모두 올바른 JSON인지 확인한다.
```

## 입력 JSON 형식

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
      "exampleIds": []
    }
  ]
}
```

## 수정 대상 파일

- `assets/json/japanese_words.json`: 단어 본문 데이터
- `assets/json/example_sentences.json`: 예문과 한국어 번역
- `assets/json/chinese_chars.json`: 단어와 예문에 포함된 한자 정보
- `assets/json/dataVersion.json`: 데이터 버전, 변경 설명, 수정 날짜

## 핵심 원칙

- 기존 데이터 우선.
- 중복 표현 추가 금지.
- 50개 단어 단위로 청크 작업.
- 속도보다 예문 품질 우선.
- 단어 등급에 맞는 예문 작성.
- 여러 예문을 쓰면 서로 완전히 다른 내용으로 작성.
- 단어와 예문에 포함된 한자는 누락 없이 보강.
- 마지막에 dataVersion 갱신.
