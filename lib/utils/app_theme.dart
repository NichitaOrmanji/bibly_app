import 'package:flutter/material.dart';

import 'app_constants.dart';

/// Светлая и тёмная темы приложения.
///
/// Вся палитра выводится из одного seed-цвета через [ColorScheme.fromSeed]:
/// чтобы перекрасить приложение, достаточно поменять [seedColor].
class AppTheme {
  AppTheme._();

  /// Глубокий синий — цвет вечернего неба: спокойствие и сосредоточенность
  /// для ежедневного чтения и молитвы.
  static const Color seedColor = Color(0xFF3949AB);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      // Базовая типографика: точечные подстройки, остальное по умолчанию.
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }
}
