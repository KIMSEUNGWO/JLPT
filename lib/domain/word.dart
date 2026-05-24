import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/question_box.dart';

/// 학습 단어. **immutable** — 변경이 필요하면 [copyWith] 를 사용.
///
/// 코스 중립적 데이터다. 소속 레벨은 [levelCode] 문자열로만 들고 다니며,
/// 표시용 [Level] 객체로의 해석은 상위 계층(활성 [Course]) 책임이다.
class Word implements QuestionBox {
  const Word({
    required this.id,
    required this.levelCode,
    required this.act,
    required this.word,
    required this.reading,
    required this.meaning,
    required this.isRead,
    required this.wrongCnt,
    required this.exampleIds,
  });

  final int id;

  /// 소속 레벨 코드 (예: `'N5'`). 활성 코스의 [Level] 로 해석된다.
  final String levelCode;
  final Act act;
  final String word;

  /// 발음 표기 (일본어 히라가나 등). reading 이 없는 코스(예: 영어)는 `null`.
  final String? reading;

  /// 사용자 언어(한국어 등) 로 된 뜻.
  final String meaning;
  final bool isRead;
  final int wrongCnt;

  /// 이 단어가 참조하는 예문 id 목록. 데이터 규칙상 항상 1개 이상.
  /// DB readback 경로에서는 ref 테이블이 비어있을 수 있어 빈 리스트가 올 수 있다.
  final List<int> exampleIds;

  /// 엄격한 JSON 파서. 누락/타입 오류 시 [FormatException] 을 던진다.
  ///
  /// 하위호환: `reading`/`meaning` 키가 없으면 기존 `hiragana`/`korean` 키로 폴백한다.
  factory Word.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) {
      throw FormatException("Word: 'id' must be int (got $id)");
    }
    final levelRaw = json['level'];
    if (levelRaw is! String || levelRaw.isEmpty) {
      throw FormatException("Word(id=$id): 'level' must be non-empty String");
    }
    final actRaw = json['act'];
    if (actRaw is! String) {
      throw FormatException("Word(id=$id): 'act' must be String");
    }
    return Word(
      id: id,
      levelCode: levelRaw,
      act: Act.valueOf(actRaw),
      word: _str(json, 'word', id),
      reading: _nullableStr(json, 'reading', 'hiragana', id),
      meaning: _strFallback(json, 'meaning', 'korean', id),
      isRead: false,
      wrongCnt: 0,
      exampleIds: _exampleIds(json, id),
    );
  }

  static String _str(Map<String, dynamic> json, String key, int id) {
    final v = json[key];
    if (v is! String) {
      throw FormatException("Word(id=$id): '$key' must be String");
    }
    return v;
  }

  /// [key] 우선, 없으면 [legacyKey] 로 폴백하는 required String.
  static String _strFallback(
    Map<String, dynamic> json,
    String key,
    String legacyKey,
    int id,
  ) {
    final v = json[key] ?? json[legacyKey];
    if (v is! String) {
      throw FormatException(
        "Word(id=$id): '$key' (or '$legacyKey') must be String",
      );
    }
    return v;
  }

  /// [key] 우선, 없으면 [legacyKey] 로 폴백하는 nullable String.
  static String? _nullableStr(
    Map<String, dynamic> json,
    String key,
    String legacyKey,
    int id,
  ) {
    final v = json[key] ?? json[legacyKey];
    if (v == null) return null;
    if (v is! String) {
      throw FormatException(
        "Word(id=$id): '$key' (or '$legacyKey') must be String when present",
      );
    }
    return v;
  }

  static List<int> _exampleIds(Map<String, dynamic> json, int id) {
    final raw = json['exampleIds'];
    if (raw is! List) {
      throw FormatException(
        "Word(id=$id): 'exampleIds' must be a List<int> (got ${raw.runtimeType})",
      );
    }
    if (raw.isEmpty) {
      return [];
    }
    final out = <int>[];
    for (var i = 0; i < raw.length; i++) {
      final v = raw[i];
      if (v is! int) {
        throw FormatException(
          "Word(id=$id): exampleIds[$i] must be int (got $v)",
        );
      }
      out.add(v);
    }
    return List<int>.unmodifiable(out);
  }

  Word copyWith({
    String? levelCode,
    Act? act,
    String? word,
    String? reading,
    String? meaning,
    bool? isRead,
    int? wrongCnt,
    List<int>? exampleIds,
  }) {
    return Word(
      id: id,
      levelCode: levelCode ?? this.levelCode,
      act: act ?? this.act,
      word: word ?? this.word,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      isRead: isRead ?? this.isRead,
      wrongCnt: wrongCnt ?? this.wrongCnt,
      exampleIds: exampleIds ?? this.exampleIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Word && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Word(id=$id, level=$levelCode, word=$word)';

  @override
  String getTerm() => word;

  @override
  String getMeaning() => meaning;
}
