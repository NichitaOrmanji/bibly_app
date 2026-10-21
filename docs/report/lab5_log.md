# ЛР5 — Интеграция с собственным backend-ом: журнал

Commit защиты ЛР4 (для `git diff --stat` в Задании 5): `7e385c6`.

## Шаг 0. Где взять backend-шаблон

В курсе FCIM.PAM21.2 на ELSE (раздел CURS) есть папка **«PAM - BackEnd (project example)»**
с архивами портов: dart, dotnet, go, java, node, python, rust. Скачан `dart.zip`.
Из учебника «PAM - Book» скачаны главы Cap08 (HTTP и JSON) и Cap09 (локальное хранение):
на них ссылается методичка (C8, C9).

**Проблема:** в архиве только сам сервер. Файлов `openapi.yaml` и набора тестов
`conformance/` в нём нет (README ссылается на `../openapi.yaml` и `../conformance`,
то есть на папки уровнем выше, которые на ELSE не выложены).
**Решение (временное):** до получения набора от преподавателя базовый контракт
проверяется собственным smoke-тестом (см. Задание 2); прогон conformance добавлю,
когда набор появится.

## Задание 1. Сервер: запуск и curl

1. Выбран **порт на Dart**: Dart уже стоит вместе с Flutter, и приложение и сервер
   на одном языке. Порт скопирован в `server/` (без служебных файлов macOS
   `.DS_Store`/`__MACOSX` и без `.dart_tool`).
2. `cd server && dart pub get`: зависимости shelf, shelf_router, shelf_multipart,
   sqlite3, crypto.
3. **Проблема:** на Windows `package:sqlite3` ищет `sqlite3.dll`.
   **Решение:** взята копия из `Python313\DLLs\sqlite3.dll` и положена рядом с
   сервером, файл добавлен в `server/.gitignore`.
4. `dart run` → `Backend listening on http://localhost:8080`;
   `GET /health` → `{"status":"ok"}`. `app.db` создался сам.
5. Сессия curl по контракту (полный вывод — `docs/report/curl_l5_task1.txt`):
   - `GET /notes` без token-а → **401** `UNAUTHORIZED`;
   - `POST /auth/register` → **201** `{token, user}`;
   - повторный register с тем же email → **409** `EMAIL_TAKEN`;
   - `GET /notes` с token-ом → **200** `{"items":[],"page":1,"limit":20,"total":0}`,
     пустой пагинированный конверт;
   - `POST /notes` → **201**, `id` выдал сервер;
   - `GET /notes?search=Покуп` → в `items` одна заметка: поиск выполняется на сервере;
   - заметка Ana, запрошенная token-ом Ion → **404**, а не 403: сервер не раскрывает,
     что чужой объект существует.
6. **Проблема:** `curl -G --data-urlencode 'search=Покуп'` в Git Bash вернул
   `Bad Request`. curl на Windows кодирует кириллицу из командной строки в cp1251
   (`%CF%EE…`), а сервер ждёт UTF-8. **Решение:** передать строку, закодированную
   в UTF-8 (`%D0%9F%D0%BE…`). С ней сервер находит заметку. Это особенность
   консоли Windows, а не сервера: приложение на Flutter кодирует URL в UTF-8.
7. `flutter analyze` в корне проекта — без ошибок, папка `server/` ему не мешает.

## Задание 2. Backend становится нашим: сущности Bibly

Сущность-пример `notes` не тронута. Рядом добавлены сущности Bibly: для каждой —
`CREATE TABLE IF NOT EXISTS` в `server/lib/db.dart`, файл-модуль по образцу `notes.dart`,
маршруты в `server/bin/server.dart` под тем же `requireAuth`. Один commit на сущность.

| Сущность | Таблицы | Маршруты | Commit |
|---|---|---|---|
| Записи дневника (Дневник + Скиния) | `entries` | `GET/POST /entries`, `GET/PUT/DELETE /entries/{id}`; `?page=&limit=&search=` | `5f37073` |
| «Мой день» | `day_plan`, `daily_tasks`, `task_done` | `GET /plans/today`, `PATCH /plans/today/tasks/{id}` | `81c8a0b` |
| «Вместе» | `reading_groups`, `group_members`, `group_leaves`, `feed` | `GET /groups`, `DELETE /groups/{id}/membership`, `GET /feed` | `2c8d2c1` |
| Библия | `books`, `chapter_headings`, `verses`, `searches` | `GET /books`, `GET /books/{id}/chapters/{n}`, `GET /search?q=`, `GET /me/searches` | `8f3d4f6` |
| Профиль | `profiles` | `GET/PUT /profile` | `1561fb3` |

Решения и проблемы:
1. **Данные пользователя и справочные данные.** Записи, отметки плана, выход из групп,
   история поиска и профиль принадлежат пользователю (`user_id`, паттерн шаблона).
   Книги, стихи, план дня, группы и лента общие: их заполняет `server/lib/seed.dart`
   при каждом старте через `INSERT OR IGNORE` с постоянными id, поэтому перезапуск
   не создаёт дублей. Это те же данные, что были в `mock_data.dart`.
2. **Проблема:** поиск по кириллице. SQLite `LIKE` и `lower()` не учитывают регистр
   только для латиницы: «НИКОДИМ» не находит «Никодим».
   **Решение:** в `entries` хранится колонка `search_text`, текст в нижнем регистре,
   его вычисляет Dart (`toLowerCase()` знает кириллицу). Поиск стихов в Библии
   фильтрует строки в Dart.
3. **Проблема:** поиск «Ин 3:16» находил ещё и «Ин 3:1». Основа слова «ин » совпадала
   с «один из» в тексте. **Решение:** запрос с цифрами считается ссылкой и ищется
   только по ссылке.
4. **Выход из группы** — `DELETE /groups/{id}/membership` → 204. Повторный выход или
   несуществующая группа → 404: «не состою» и «не существует» выглядят одинаково,
   как с чужой заметкой.
5. **Профиль** — отдельный `GET/PUT /profile`. Базовый `GET /me` шаблона не тронут
   и по-прежнему отвечает `{id, email, name}`, поэтому контракт не нарушен. Чужой
   email в `PUT /profile` → 409 `EMAIL_TAKEN`.
6. В CORS добавлен метод `PATCH` для `PATCH /plans/today/tasks/{id}`.
7. Проверка на чистой базе (`app.db` удалён): собственный smoke-тест прогоняет базовый
   контракт шаблона (health, register/login/me, notes CRUD, пагинация, поиск,
   404 на чужое, 204, upload/download файлов) и все маршруты Bibly:
   **PASS — 48/48** (полный вывод — `docs/report/api_check_l5.txt`).
   Это замена набора conformance до тех пор, пока он не получен.

## Задание 3. Настоящий вход: форма ЛР3 + token в shared_preferences

1. `flutter pub add http shared_preferences`.
   **Замечание:** Flutter попросил включить «Режим разработчика» Windows (symlink-и
   для плагинов desktop-сборок). На сборку под Android это не повлияло:
   APK собрался без него.
2. Новые файлы в `lib/data/`:
   - `token_store.dart` — `TokenStore`: `read()` / `save()` / `clear()` поверх
     shared_preferences, ключ `auth_token`. Только этот файл знает, где лежит пропуск.
     **Пароль не сохраняется нигде.**
   - `api_message.dart` — `apiMessage(res)`: вскрывает конверт ошибки
     `{"error":{"code","message"}}` и переводит `code` на русский
     (`UNAUTHORIZED` → «Неверный email или пароль», `EMAIL_TAKEN` → «Аккаунт с этим
     email уже существует», …). Тело вне контракта → «Ошибка сервера (код)».
   - `auth_api.dart` — `AuthApi`: `register`, `login`, `logout`. Общий `_post` с
     `.timeout(8 с)` и тремя слоями отказа: `SocketException` / `TimeoutException`
     (дорога), `statusCode` → `apiMessage` (ответ сервера), `FormatException` /
     `TypeError` (тело-сюрприз). Всё сходится в `Err(msg)`. При успехе token уходит
     в `TokenStore.save`.
3. `login_screen.dart`: переключатель `_isRegister` и поле «Имя» (только при
   регистрации, валидатор `Validators.name` из ЛР3). Валидаторы ЛР3 не тронуты,
   переписан только submit: `context.read<AuthApi>()` → `Ok` → `context.go('/day')`,
   `Err` → SnackBar. Флаг `_busy` гасит кнопку на время запроса (защита от
   двойного submit), проверка `mounted` после `await`.
4. Запуск решает по token-у: в `router.dart` `final router = GoRouter(...)` стал
   `late final GoRouter router;` плюс функция `buildRouter(initialLocation:)`.
   `main()` стал `async`: `WidgetsFlutterBinding.ensureInitialized()` →
   `TokenStore().read()` → `router = buildRouter(initialLocation: loggedIn ? '/day' : '/login')`.
   `createApp(auth:)` кладёт в корень `Provider<AuthApi>`; адрес сервера —
   константа `apiBase = 'http://10.0.2.2:8080'` (для эмулятора ноутбук — 10.0.2.2).
5. Профиль: «Выйти» → подтверждение → `AuthApi.logout()` (token стёрт) →
   `context.go('/login')`.
6. **Проблема:** Android 9+ блокирует обычный `http://`, а в основном манифесте не
   было разрешения INTERNET (оно было только в debug). **Решение:** в
   `android/app/src/main/AndroidManifest.xml` добавлены
   `<uses-permission android.permission.INTERNET>` и
   `android:usesCleartextTraffic="true"` (сервер лабораторной — без TLS).
7. Тесты: виджет-тестам нужен `auth`, поэтому подставлена `FakeAuthApi`, которая
   впускает без сервера (тесты проверяют экраны, а не сеть). Router строится один
   раз в `setUpAll`. Новый `test/auth_test.dart`: перевод конверта
   (`apiMessage`), `TokenStore` (save → read → clear на mock-prefs), SnackBar с
   ошибкой сервера, режим регистрации с полем имени. Всего **33 теста — все проходят**,
   `flutter analyze` без замечаний.
8. Проверка на эмуляторе (сервер на ноутбуке, `http://10.0.2.2:8080`):
   - первый запуск без token-а → экран входа;
   - регистрация `nikita@bibly.md` → сервер: `POST [201] /auth/register` → «Мой день»
     (`01_register_form.png`, `02_after_register.png`);
   - приложение убито (`am force-stop`) и открыто снова → сразу «Мой день», без входа
     (`03_reopen_logged_in.png`). В prefs лежит `flutter.auth_token`
     (`docs/report/prefs_token_l5.txt`);
   - «Выйти» → prefs пустые (`<map />`) → экран входа (`04_after_logout.png`);
   - неверный пароль → сервер: `POST [401] /auth/login` → SnackBar
     «Неверный email или пароль» (`05_wrong_password.png`);
   - верный пароль → `POST [200] /auth/login` → «Мой день».
   Данные на экранах пока из mock-ов: на сервер их переведут Задания 4–5.
9. Логи эмулятора показывают ошибки Impeller «Could not link pipeline program» —
   это особенность GPU эмулятора, экран рисуется нормально.

## Задание 4. Http-хранилища: интерфейсы ЛР4 воплощены

Железное правило соблюдено: **ни один интерфейс ЛР4 не изменён** (в
`profile_repository.dart` поправлен только комментарий с адресом: `/me` → `/profile`).
Рядом с mock-ами встали вторые реализации, `main.dart` пока не тронут (замена —
Задание 5).

1. **Сущности учат язык сервера.** У сущностей в `lib/models/` появились
   `fromJson` (а у `DiaryEntry` и `UserProfile`, которые отправляются на сервер, ещё
   и `toJson`): `DiaryEntry`, `DailyTask`, `DayPlan`, `Verse`, `BibleBook`,
   `ChapterText`, `ChapterVerse`, `ReadingGroup`, `FriendActivity`, `UserProfile`.
   - `toJson` — без `id`: идентичность даёт сервер.
   - Cast-ы `as` — граница доверия: чужой формат → `TypeError` → `Err`.
   - Перечисления приходят строками (`'reflection'`, `'old'`): неизвестное значение →
     `FormatException`, а не падение.
   - `progress` разбирается как `num` → `toDouble()`: JSON может прислать `1` как int.
   ChangeNotifier-модели (`*_model.dart`) не тронуты.
2. **`lib/data/http/api_client.dart` — общий скелет запроса.** В методичке каждый
   метод повторяет один и тот же скелет. У нас 15 методов в 5 хранилищах, поэтому
   скелет вынесен в `ApiClient._send` и написан один раз:
   `Authorization: Bearer <token>` → `.timeout(8 с)` → **401**: `_sessionDied()`
   (token стёрт из prefs + callback `onUnauthorized` — его задаёт корень, хранилище
   router не знает) → **не тот статус**: `Err(apiMessage(res))` → разбор JSON →
   `Ok(parse(json))`. Исключения ловятся по типам: `SocketException` /
   `http.ClientException` (дорога), `TimeoutException`, `FormatException` /
   `TypeError` (тело-сюрприз). Общего `catch (e)` нет.
3. **Пять хранилищ** в `lib/data/http/`: `HttpDiaryRepository`,
   `HttpDailyRepository`, `HttpBibleRepository`, `HttpCommunityRepository`,
   `HttpProfileRepository`, каждое `implements` свой интерфейс ЛР4. Хорошие статусы:
   GET/PUT/PATCH → 200, POST → 201, DELETE → 204 (`Ok(null)` без `jsonDecode`).
   `fetchAll` дневника вскрывает пагинированный конверт `{items, page, limit, total}`.
4. **Проблема: кириллица.** Сервер шаблона отвечает `content-type: application/json`
   без `charset`. Пакет `http` в таком случае читает `res.body` как latin1, и
   «Родиться» превратилось бы в «Ð Ð¾Ð´…». **Решение:** тело декодируется явно:
   `jsonDecode(utf8.decode(res.bodyBytes))`. На это есть тест.
5. **Тесты** `test/http_repository_test.dart` (10): «провод» подменён
   `MockClient` через `http.runWithClient`, а код хранилищ работает настоящий.
   Проверены Bearer-заголовок, разбор конверта, кириллица, POST без id → 201, DELETE 204
   без разбора тела, 404 → «Запись не существует», 401 → token стёрт и корень
   извещён, `SocketException` → «Нет сети», HTML → «Ответ не тот, что обещан»,
   JSON не той формы → `TypeError` → тот же Err, PATCH отметки, кодирование
   кириллицы в запросе поиска.
6. **Проверка против настоящего сервера** `test/live_server_test.dart` (5):
   регистрация нового пользователя, затем все пять хранилищ (полный CRUD дневника,
   план и отметка, книги/глава/404/поиск/история, группы/лента/выход, профиль).
   Обычный `flutter test` её пропускает; при работающем сервере:
   `flutter test test/live_server_test.dart --dart-define=BIBLY_SERVER=http://localhost:8080`
   → **5/5**. Вывод обоих наборов — `docs/report/http_tests_l5.txt`.
7. Итог: `flutter analyze` — без замечаний; `flutter test` — 43 прошли,
   5 живых пропущены (без сервера).
