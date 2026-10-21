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
**Решение:** <будет дописано>.

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
