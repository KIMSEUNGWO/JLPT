abstract class Constant {
  static const String _BASE_URL =
      'https://raw.githubusercontent.com/KIMSEUNGWO/JLPT/refs/heads/main/assets/json';
  static const String VERSION_LINK = '$_BASE_URL/dataVersion.json';
  static const String CHINESE_CHARS_LINK = '$_BASE_URL/chinese_chars.json';
  static const String JAPANESE_WORDS_LINK = '$_BASE_URL/japanese_words.json';
  static const String EXAMPLE_SENTENCES_LINK =
      '$_BASE_URL/example_sentences.json';
}
