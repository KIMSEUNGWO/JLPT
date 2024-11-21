
import 'package:flutter/material.dart';

class CustomSnackBar {

  static const CustomSnackBar instance = CustomSnackBar();
  const CustomSnackBar();

  message(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14
          ),
        ), // 컨텐츠 표시내용
        duration: const Duration(seconds: 2), // 지속시간
        behavior: SnackBarBehavior.floating, // 화면 하단
        backgroundColor: const Color(0xFF414650).withOpacity(.85),
        elevation: 0, // 그림자 없애기
        shape: RoundedRectangleBorder( // 모서리를 둥글게 변경
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }
}