import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlpt_app/app/app.dart';
import 'package:jlpt_app/app/bootstrap.dart';
import 'package:jlpt_app/component/local_storage.dart';
import 'package:jlpt_app/data/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await openDatabase();
  await LocalStorage.initInstance(); // notifier build()에서 동기적으로 사용

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const JlptApp(),
    ),
  );
}
