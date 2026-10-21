import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/auth_api.dart';
import 'data/bible_repository.dart';
import 'data/community_repository.dart';
import 'data/daily_repository.dart';
import 'data/diary_repository.dart';
import 'data/http/api_client.dart';
import 'data/http/http_bible_repository.dart';
import 'data/http/http_community_repository.dart';
import 'data/http/http_daily_repository.dart';
import 'data/http/http_diary_repository.dart';
import 'data/http/http_profile_repository.dart';
import 'data/profile_repository.dart';
import 'data/token_store.dart';
import 'models/bible_model.dart';
import 'models/community_model.dart';
import 'models/day_plan_model.dart';
import 'models/diary_model.dart';
import 'models/profile_model.dart';
import 'router.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

/// Адрес сервера. Эмулятор Android не знает «localhost» ноутбука:
/// для него ноутбук — 10.0.2.2. На десктопе — localhost,
/// на настоящем телефоне — IP ноутбука в локальной сети.
const apiBase = 'http://10.0.2.2:8080';

Future<void> main() async {
  // shared_preferences — плагин: до runApp нужен готовый binding.
  WidgetsFlutterBinding.ensureInitialized();
  final tokens = TokenStore();
  // Запуск решает по token-у: есть пропуск — сразу в приложение.
  final loggedIn = await tokens.read() != null;
  router = buildRouter(initialLocation: loggedIn ? '/day' : '/login');

  // ЛР5: источник данных — сервер. Одна строка на хранилище — и всё.
  // 401 (token умер) → ApiClient стёр token → корень уводит на вход;
  // навигирует корень, хранилища router не знают.
  final api = ApiClient(
    apiBase,
    tokens,
    onUnauthorized: () => router.go('/login'),
  );
  runApp(
    createApp(
      auth: AuthApi(apiBase, tokens),
      daily: HttpDailyRepository(api),
      diary: HttpDiaryRepository(api),
      bible: HttpBibleRepository(api),
      community: HttpCommunityRepository(api),
      profile: HttpProfileRepository(api),
    ),
  );
}

/// Корень композиции: модели получают хранилища через конструктор.
/// Типы параметров — ИНТЕРФЕЙСЫ: ни модели, ни экраны не знают, http там
/// или тестовый дублёр. main() передаёт http-хранилища, тесты — свои.
Widget createApp({
  required AuthApi auth,
  required DailyRepository daily,
  required DiaryRepository diary,
  required BibleRepository bible,
  required CommunityRepository community,
  required ProfileRepository profile,
}) {
  return Provider<AuthApi>.value(
    // Вход/регистрация/выход — экран входа и профиль читают его через read.
    value: auth,
    // Новый вход — новый ключ — новые модели: данные прошлого пользователя
    // не переживают выход, а первая загрузка идёт уже с новым token-ом.
    child: ValueListenableBuilder<int>(
      valueListenable: auth.session,
      builder: (context, session, _) => MultiProvider(
        key: ValueKey(session),
        providers: [
          // Модели — фабрикой: Provider создаёт лениво и сам вызывает dispose;
          // ..load() запускает первую загрузку вместе с созданием.
          ChangeNotifierProvider(create: (_) => DayPlanModel(daily)..load()),
          ChangeNotifierProvider(create: (_) => DiaryModel(diary)..load()),
          ChangeNotifierProvider(create: (_) => BibleModel(bible)..load()),
          ChangeNotifierProvider(
            create: (_) => CommunityModel(community)..load(),
          ),
          ChangeNotifierProvider(create: (_) => ProfileModel(profile)..load()),
        ],
        child: const BiblyApp(), // MaterialApp.router — нетронут с ЛР3
      ),
    ),
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
