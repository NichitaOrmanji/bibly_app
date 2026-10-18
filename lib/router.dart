import 'package:go_router/go_router.dart';

import 'screens/bible_screen.dart';
import 'screens/book_screen.dart';
import 'screens/chapter_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/entry_screen.dart';
import 'screens/group_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/tabernacle_lock_screen.dart';
import 'screens/tabernacle_screen.dart';
import 'screens/together_screen.dart';

/// Карта маршрутов приложения: у каждого экрана есть адрес.
/// Router — глобальный объект, создаётся один раз; после изменения карты
/// нужен restart (R), hot reload (r) её не перечитывает.
final router = GoRouter(
  initialLocation: '/login', // приложение стартует со входа
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    // Временно: вкладки всё ещё в MainShell, StatefulShellRoute — следующий шаг.
    GoRoute(path: '/day', builder: (context, state) => const MainShell()),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(path: '/bible', builder: (context, state) => const BibleScreen()),
    GoRoute(
      path: '/bible/:bookId', // /bible/43 — главы книги «От Иоанна»
      builder: (context, state) {
        final bookId = int.parse(state.pathParameters['bookId']!);
        return BookScreen(bookId: bookId);
      },
    ),
    GoRoute(
      path: '/bible/:bookId/:chapter', // /bible/43/3 — От Иоанна, глава 3
      builder: (context, state) {
        // Параметры пути — всегда String: адрес это текст, int.parse — наш.
        final bookId = int.parse(state.pathParameters['bookId']!);
        final chapter = int.parse(state.pathParameters['chapter']!);
        return ChapterScreen(bookId: bookId, chapter: chapter);
      },
    ),
    GoRoute(path: '/diary', builder: (context, state) => const DiaryScreen()),
    GoRoute(
      path: '/diary/unlock',
      builder: (context, state) => const TabernacleLockScreen(),
    ),
    GoRoute(
      path: '/diary/tabernacle',
      builder: (context, state) => const TabernacleScreen(),
    ),
    GoRoute(
      path: '/diary/tabernacle/:id', // приватная запись: /diary/tabernacle/101
      builder: (context, state) =>
          EntryScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    // Фиксированные адреса (/diary/unlock, /diary/tabernacle) стоят ВЫШЕ
    // переменного /diary/:id — маршруты пробуются сверху вниз.
    GoRoute(
      path: '/diary/:id', // /diary/5
      builder: (context, state) =>
          EntryScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/together',
      builder: (context, state) => const TogetherScreen(),
    ),
    GoRoute(
      path: '/together/:groupId', // /together/2
      builder: (context, state) =>
          GroupScreen(groupId: int.parse(state.pathParameters['groupId']!)),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
