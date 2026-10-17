import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const BiblyApp());
}

class BiblyApp extends StatefulWidget {
  const BiblyApp({super.key});

  @override
  State<BiblyApp> createState() => _BiblyAppState();
}

class _BiblyAppState extends State<BiblyApp> {
  // По умолчанию тема следует системным настройкам.
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: HomeScreen(themeMode: _themeMode),
        );
      },
    );
  }
}
