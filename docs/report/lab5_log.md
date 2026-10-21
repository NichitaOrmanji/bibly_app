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
