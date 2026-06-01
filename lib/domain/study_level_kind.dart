import 'package:jlpt_app/domain/level.dart';

/// 카나 학습 레벨 코드. 카나는 **스크립트(히라가나/가타카나) × 모드(문자/단어)**
/// 로 완전히 분리된 4개 레벨로 표현된다.
abstract final class StudyLevelCodes {
  static const hiraganaChar = 'HIRAGANA_CHAR';
  static const hiraganaWord = 'HIRAGANA_WORD';
  static const katakanaChar = 'KATAKANA_CHAR';
  static const katakanaWord = 'KATAKANA_WORD';
}

/// 카나(히라가나/가타카나) 학습 분기 헬퍼. JLPT 단어 학습과 카나 학습을
/// 위젯/제너레이터에서 구분할 때 사용한다.
extension StudyLevelKind on Level {
  bool get isHiragana =>
      code == StudyLevelCodes.hiraganaChar ||
      code == StudyLevelCodes.hiraganaWord;

  bool get isKatakana =>
      code == StudyLevelCodes.katakanaChar ||
      code == StudyLevelCodes.katakanaWord;

  bool get isKana => isHiragana || isKatakana;

  bool get isJlpt => !isKana;

  /// 오십음도 낱자 학습 레벨인가 (false 면 카나 단어 학습 레벨).
  bool get isKanaChar =>
      code == StudyLevelCodes.hiraganaChar ||
      code == StudyLevelCodes.katakanaChar;

  /// 카나 스크립트 이름 ('히라가나'/'가타카나'). 카나가 아니면 null.
  String? get kanaScriptName {
    if (isHiragana) return '히라가나';
    if (isKatakana) return '가타카나';
    return null;
  }

  /// 페이지 제목용 라벨 (예: '히라가나 문자', '가타카나 단어', 'JLPT N5').
  String get studyTitle {
    final script = kanaScriptName;
    if (script == null) return 'JLPT $label';
    return '$script ${isKanaChar ? '문자' : '단어'}';
  }

  /// 묶음/잔여 개수 문구에 쓰는 항목 이름 ('문자'/'단어').
  String get itemLabel => isKanaChar ? '문자' : '단어';
}
