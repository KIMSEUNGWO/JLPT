import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question_box.dart';

/// 학습 단어. **immutable** — 변경이 필요하면 [copyWith] 를 사용.
class Word implements QuestionBox {
  const Word({
    required this.id,
    required this.level,
    required this.act,
    required this.word,
    required this.hiragana,
    required this.korean,
    required this.isRead,
    required this.wrongCnt,
    required this.exampleIds,
  });

  final int id;
  final Level level;
  final Act act;
  final String word;
  final String hiragana;
  final String korean;
  final bool isRead;
  final int wrongCnt;

  /// 이 단어가 참조하는 예문 id 목록. 데이터 규칙상 항상 1개 이상.
  /// DB readback 경로에서는 ref 테이블이 비어있을 수 있어 빈 리스트가 올 수 있다.
  final List<int> exampleIds;

  /// 엄격한 JSON 파서. 누락/타입 오류 시 [FormatException] 을 던진다.
  factory Word.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) {
      throw FormatException("Word: 'id' must be int (got $id)");
    }
    final levelRaw = json['level'];
    if (levelRaw is! String) {
      throw FormatException("Word(id=$id): 'level' must be String");
    }
    final actRaw = json['act'];
    if (actRaw is! String) {
      throw FormatException("Word(id=$id): 'act' must be String");
    }
    return Word(
      id: id,
      level: Level.valueOf(levelRaw),
      act: Act.valueOf(actRaw),
      word: _str(json, 'word', id),
      hiragana: _str(json, 'hiragana', id),
      korean: _str(json, 'korean', id),
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
    Level? level,
    Act? act,
    String? word,
    String? hiragana,
    String? korean,
    bool? isRead,
    int? wrongCnt,
    List<int>? exampleIds,
  }) {
    return Word(
      id: id,
      level: level ?? this.level,
      act: act ?? this.act,
      word: word ?? this.word,
      hiragana: hiragana ?? this.hiragana,
      korean: korean ?? this.korean,
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
  String toString() => 'Word(id=$id, level=${level.name}, word=$word)';

  @override
  String getJapanese() => word;

  @override
  String getKorean() => korean;
}
