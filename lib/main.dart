import 'package:flutter/material.dart';

import 'router.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

void main() => runApp(const BiblyApp());

class BiblyApp extends StatelessWidget {
  const BiblyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Светлая или тёмная тема — по настройкам системы.
      themeMode: ThemeMode.system,
      // Навигацию принимает router; home: больше нет — старт в initialLocation.
      routerConfig: router,
    );
  }
}
