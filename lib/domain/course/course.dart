import 'package:jlpt_app/domain/course/course_data_config.dart';
import 'package:jlpt_app/domain/level.dart';

/// 한 언어 학습 트랙("코스")의 정적 정의. **immutable**.
///
/// 단어 암기·플래시카드·테스트 기능 자체는 언어 중립적이며, 언어별 차이
/// (레벨 체계, TTS locale, reading 유무, 한자류 부가 모듈 등) 는 모두 이 객체로
/// 외부화한다. 새 언어를 추가하려면 [Course] 인스턴스 + 데이터 파일만 더하면 된다
/// (`course_registry.dart` 참고).
class Course {
  const Course({
    required this.identity,
    required this.presentation,
    required this.capabilities,
    required this.levels,
    required this.data,
  });

  final CourseIdentity identity;
  final CoursePresentation presentation;
  final CourseCapabilities capabilities;

  /// DB `course` 컬럼·메타 키·스토리지 키에 쓰는 안정 식별자 (예: `'jlpt_ja'`).
  String get id => identity.id;

  /// 레벨 앞에 붙는 표시 이름 (예: `'JLPT'` → "JLPT N5").
  String get displayName => presentation.displayName;

  /// TTS 발음 locale (예: `'ja-JP'`).
  String get ttsLocale => presentation.ttsLocale;

  /// 학습 대상 언어의 사람이 읽는 이름 (예: `'일본어'`). 설정 문구 등에 사용.
  String get termLanguageLabel => presentation.termLanguageLabel;

  /// 발음 표기(reading) 토글 라벨 (예: `'히라가나'`). `null` 이면 reading 없는 코스.
  String? get readingLabel => presentation.readingLabel;

  /// 한자/문자 분해 부가 모듈을 갖는지 (일본어 한자 = true).
  bool get hasCharacterModule => capabilities.hasCharacterModule;

  /// 문자 모듈 섹션 제목 (예: `'한자'`). 모듈 없으면 `null`.
  String? get characterModuleLabel => capabilities.characterModuleLabel;

  /// 정렬된 레벨 목록 (쉬움 → 어려움).
  final List<Level> levels;

  /// 데이터 소스(asset/remote 키 + 검증 임계치).
  final CourseDataConfig data;

  bool get hasReading => readingLabel != null;

  Level? levelOrNull(String code) {
    for (final l in levels) {
      if (l.code == code) return l;
    }
    return null;
  }

  /// 코드로 레벨을 찾는다. 없으면 [ArgumentError].
  Level levelOf(String code) {
    final l = levelOrNull(code);
    if (l == null) {
      throw ArgumentError('Unknown level code "$code" in course $id');
    }
    return l;
  }
}

/// DB, sync, storage namespace 에 쓰이는 코스 식별 정보.
class CourseIdentity {
  const CourseIdentity({required this.id});

  final String id;
}

/// 화면 문구와 입력/출력 장치에 필요한 코스 표시 정보.
class CoursePresentation {
  const CoursePresentation({
    required this.displayName,
    required this.ttsLocale,
    required this.termLanguageLabel,
    required this.readingLabel,
  });

  final String displayName;
  final String ttsLocale;
  final String termLanguageLabel;
  final String? readingLabel;
}

/// 코스가 제공하는 선택 기능.
class CourseCapabilities {
  const CourseCapabilities({
    required this.hasCharacterModule,
    required this.characterModuleLabel,
  });

  final bool hasCharacterModule;
  final String? characterModuleLabel;
}
