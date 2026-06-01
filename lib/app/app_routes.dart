abstract class AppRoutes {
  static const root = '/';
  static const home = '/home';
  static const jlpt = '/jlpt';
  static const kanaHub = '/kana/:script'; // script: hiragana | katakana
  static const studyLevel = '/study/:level';
  static const studyGroup = 'group'; // /study/:level/group
  static const test = '/test';
  static const testResults = '/test/results';
  static const testResultDetail = 'detail'; // /test/results/detail
  static const settings = '/settings';

  static String kana(String script) => '/kana/$script';
  static String study(String level) => '/study/$level';
  static String studyGroupFull(String level) => '/study/$level/group';
}
