import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/bible_repository.dart';
import 'data/community_repository.dart';
import 'data/daily_repository.dart';
import 'data/diary_repository.dart';
import 'data/mock/mock_bible_repository.dart';
import 'data/mock/mock_community_repository.dart';
import 'data/mock/mock_daily_repository.dart';
import 'data/mock/mock_diary_repository.dart';
import 'data/mock/mock_network.dart';
import 'data/mock/mock_profile_repository.dart';
import 'data/profile_repository.dart';
import 'models/bible_model.dart';
import 'models/community_model.dart';
import 'models/day_plan_model.dart';
import 'models/diary_model.dart';
import 'models/profile_model.dart';
import 'router.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

void main() => runApp(createApp());

/// Корень композиции: ЗДЕСЬ (и только здесь) выбирается источник данных.
/// На L5 строки с Mock* заменяются http-реализациями — экраны и модели
/// не трогаются. Отдельная функция — чтобы тесты получали свежее
/// состояние на каждый тест.
Widget createApp() {
  final network = MockNetwork(); // на L5 исчезает вместе с mock-ами
  // Тип переменных — интерфейс: дальше никто не знает, что это mock.
  final DailyRepository daily = MockDailyRepository(network);
  final DiaryRepository diary = MockDiaryRepository(network);
  final BibleRepository bible = MockBibleRepository(network);
  final CommunityRepository community = MockCommunityRepository(network);
  final ProfileRepository profile = MockProfileRepository(network);

  return MultiProvider(
    providers: [
      // Леса демонстрации аварии (переключатель в профиле) — исчезают на L5.
      // Не ChangeNotifier и освобождать нечего — поэтому .value.
      Provider<MockNetwork>.value(value: network),
      // Модели — фабрикой: Provider создаёт лениво и сам вызывает dispose;
      // ..load() запускает первую загрузку вместе с созданием.
      ChangeNotifierProvider(create: (_) => DayPlanModel(daily)..load()),
      ChangeNotifierProvider(create: (_) => DiaryModel(diary)..load()),
      ChangeNotifierProvider(create: (_) => BibleModel(bible)..load()),
      ChangeNotifierProvider(create: (_) => CommunityModel(community)..load()),
      ChangeNotifierProvider(create: (_) => ProfileModel(profile)..load()),
    ],
    child: const BiblyApp(), // MaterialApp.router — нетронут с ЛР3
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
