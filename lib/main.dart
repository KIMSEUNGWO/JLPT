import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:jlpt_app/db/db_hive.dart';
import 'package:jlpt_app/db/db_version_container.dart';
import 'package:jlpt_app/domain/act.dart';
import 'package:jlpt_app/domain/box/chinese_char_box.dart';
import 'package:jlpt_app/domain/chinese_char.dart';
import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/word.dart';
import 'package:jlpt_app/domain/box/japan_word_box.dart';
import 'package:jlpt_app/initdata/init.dart';

import 'package:path_provider/path_provider.dart' as path_provider;


void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화 전에 기존 데이터 삭제
  await clearHiveData();

  await Hive.initFlutter(); // NoSQL init

  Hive.registerAdapter(ChineseCharAdapter());
  Hive.registerAdapter(WordAdapter());
  Hive.registerAdapter(LevelAdapter());
  Hive.registerAdapter(ActAdapter());
  Hive.registerAdapter(JapanWordBoxAdapter());
  Hive.registerAdapter(ChineseCharBoxAdapter());

  // Box 열기
  await Hive.openBox(DBHive.JAPAN_WORDS_BOX);
  await Hive.openBox(DBHive.CHINESE_CHAR_BOX);
  await Hive.openBox(VersionController.VERSION_BOX);

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> clearHiveData() async {
  // 모든 박스 닫기
  await Hive.close();

  // Hive 디렉토리 가져오기
  final directory = await path_provider.getApplicationDocumentsDirectory();
  final path = directory.path;

  // Hive 파일들 삭제
  Directory(path).listSync().forEach((file) {
    if (file.path.contains('.hive')) {
      file.deleteSync();
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeData(),
      home: const InitWidget(),
    );
  }
}

themeData() {
  return ThemeData(
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: const Color(0xFFF1F3F5),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: Color(0xFFF1F3F5),
      titleTextStyle: TextStyle(
        color: Color(0xFF292929),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    ),

    colorScheme: const ColorScheme.light(

        primary: Color(0xFF7373C9), // 메인 컬러 1
        secondary: Color(0xFFF8F9FD), // 메인 컬러 2

        onPrimary: Color(0xFF292929), // 폰트 컬러 1
        onSurface: Color(0xFF686868), // 폰트 컬러 2
        onTertiary: Color(0xFF888888), // 폰트 컬러 3



        error: Color(0xFFFF5D5D)
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      displayMedium: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      displaySmall: TextStyle(
          fontSize: 16,
      ),
      bodyLarge: TextStyle(
          fontSize: 14,
      ),
      bodyMedium: TextStyle(
          fontSize: 12,
      ),
      bodySmall: TextStyle(
          fontSize: 10,
      ),
    ),

  );
}