import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

void main() => runApp(const BiblyApp());

class BiblyApp extends StatelessWidget {
  const BiblyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Светлая или тёмная тема — по настройкам системы.
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
