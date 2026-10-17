import 'package:flutter/material.dart';

/// Кнопка переключения светлой/тёмной темы.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, required this.themeMode});

  final ValueNotifier<ThemeMode> themeMode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      tooltip: isDark ? 'Светлая тема' : 'Тёмная тема',
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
      },
    );
  }
}
