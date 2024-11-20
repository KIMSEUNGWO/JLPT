import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/initdata/init.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
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