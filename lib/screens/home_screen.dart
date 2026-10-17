import 'package:flutter/material.dart';

import '../utils/app_constants.dart';
import '../widgets/theme_toggle_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.themeMode});

  final ValueNotifier<ThemeMode> themeMode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [ThemeToggleButton(themeMode: themeMode)],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Text(
            'Добро пожаловать в ${AppConstants.appName}',
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
