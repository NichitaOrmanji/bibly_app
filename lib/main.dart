import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock_data.dart';
import 'models/day_plan_model.dart';

import 'router.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

void main() => runApp(createApp());

/// Приложение вместе с моделями состояния. Отдельная функция —
/// чтобы тесты получали свежее состояние на каждый тест.
Widget createApp() {
  return ChangeNotifierProvider(
    // Фабрика, а не готовый экземпляр: Provider создаёт модель лениво
    // и сам вызывает её dispose.
    create: (_) => DayPlanModel(MockData.todayPlan),
    child: const BiblyApp(),
  );
}

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
