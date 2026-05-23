import 'package:flutter/material.dart';

class CustomSnackBar {
  static const CustomSnackBar instance = CustomSnackBar();
  const CustomSnackBar();

  void message(BuildContext context, String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: theme.snackBarTheme.contentTextStyle),
        duration: const Duration(seconds: 2), // 지속시간
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }
}
