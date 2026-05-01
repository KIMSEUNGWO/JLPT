import 'package:flutter/material.dart';
import 'package:jlpt_app/app/router.dart';
import 'package:jlpt_app/core/theme/app_theme.dart';

class JlptApp extends StatelessWidget {
  const JlptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JLPT GO',
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
