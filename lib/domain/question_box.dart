/// 4지선다 테스트에 출제될 수 있는 학습 항목.
///
/// [getTerm] 은 학습 대상(외국어 단어/문법), [getMeaning] 은 사용자 언어로 된 뜻.
/// 정방향/역방향(reverse) 문제는 이 둘을 서로 바꿔 출제한다.
abstract class QuestionBox {
  String getTerm();
  String getMeaning();
}
