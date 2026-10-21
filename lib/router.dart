import 'package:go_router/go_router.dart';

import 'screens/bible_screen.dart';
import 'screens/book_screen.dart';
import 'screens/chapter_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/entry_screen.dart';
import 'screens/group_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_day_screen.dart';
import 'screens/new_entry_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/tabernacle_lock_screen.dart';
import 'screens/tabernacle_screen.dart';
import 'screens/together_screen.dart';
import 'widgets/app_shell.dart';

/// Помощник: id из адреса. Параметр пути — всегда String,
/// а знак ! оправдан: маршрут гарантирует, что параметр есть.
int _param(GoRouterState state, String name) =>
    int.parse(state.pathParameters[name]!);

/// Router приложения — глобальный объект, создаётся один раз.
/// С ЛР5 его строит main(): стартовый адрес зависит от сохранённого token-а,
/// а прочитать token можно только асинхронно — поэтому late, а не сразу.
late final GoRouter router;

/// Карта маршрутов; [initialLocation] — '/login' или сразу '/day'.
/// После изменения карты нужен restart (R), hot reload (r) её не перечитывает.
GoRouter buildRouter({required String initialLocation}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    // ВНЕ shell-а: вход без вкладок.
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    // Поиск тоже вне shell-а: открывается поверх вкладок на весь экран.
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),

    // Постоянные вкладки: каждая ветка хранит свой стек и прокрутку.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        // 0 — Мой день
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/day',
              builder: (context, state) => const MyDayScreen(),
            ),
          ],
        ),
        // 1 — Библия: список книг → книга → глава
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bible',
              builder: (context, state) => const BibleScreen(),
              routes: [
                GoRoute(
                  path: ':bookId', // /bible/43
                  builder: (context, state) =>
                      BookScreen(bookId: _param(state, 'bookId')),
                  routes: [
                    GoRoute(
                      path: ':chapter', // /bible/43/3
                      builder: (context, state) => ChapterScreen(
                        bookId: _param(state, 'bookId'),
                        chapter: _param(state, 'chapter'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // 2 — Дневник и Скиния
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/diary',
              builder: (context, state) => const DiaryScreen(),
              // Пути дочерних маршрутов — относительные (без / в начале).
              // Фиксированные сегменты стоят ВЫШЕ переменного ':id':
              // маршруты пробуются сверху вниз.
              routes: [
                GoRoute(
                  // /diary/new — фиксированный сегмент, стоит ПЕРЕД ':id',
                  // иначе «new» попал бы в int.parse и приложение упало бы.
                  path: 'new',
                  builder: (context, state) {
                    // Необязательные query-параметры: ?verse=Ин 3&place=tabernacle
                    final query = state.uri.queryParameters;
                    return NewEntryScreen(
                      initialVerse: query['verse'],
                      initialPlace: query['place'] == 'tabernacle'
                          ? EntryPlace.tabernacle
                          : null,
                    );
                  },
                ),
                GoRoute(
                  path: 'unlock', // /diary/unlock — пароль Скинии
                  builder: (context, state) => const TabernacleLockScreen(),
                ),
                GoRoute(
                  path: 'tabernacle', // /diary/tabernacle — личные записи
                  builder: (context, state) => const TabernacleScreen(),
                  routes: [
                    GoRoute(
                      path: ':id', // /diary/tabernacle/101
                      builder: (context, state) =>
                          EntryScreen(id: _param(state, 'id')),
                      routes: [
                        GoRoute(
                          path: 'edit', // /diary/tabernacle/101/edit
                          builder: (context, state) =>
                              NewEntryScreen(entryId: _param(state, 'id')),
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: ':id', // /diary/5
                  builder: (context, state) =>
                      EntryScreen(id: _param(state, 'id')),
                  routes: [
                    GoRoute(
                      path: 'edit', // /diary/5/edit — та же форма, режим update
                      builder: (context, state) =>
                          NewEntryScreen(entryId: _param(state, 'id')),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // 3 — Вместе
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/together',
              builder: (context, state) => const TogetherScreen(),
              routes: [
                GoRoute(
                  path: ':groupId', // /together/2
                  builder: (context, state) =>
                      GroupScreen(groupId: _param(state, 'groupId')),
                ),
              ],
            ),
          ],
        ),
        // 4 — Профиль
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit', // /profile/edit
                  builder: (context, state) => const ProfileEditScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
