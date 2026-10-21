"""Сборка отчёта по ЛР5 в PDF.

Запуск из корня проекта:  python docs/report/build_report_l5.py
Результат: docs/report/PAM_L5_NichitaOrmanji.pdf (и .html рядом).

Титульный лист, стили, вставка кода и git log — общие с ЛР2
(build_report.py, словарь TITLE: группа, тема).
"""

import base64
import html
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import build_report as base  # noqa: E402

SHOTS = base.REPORT / "screenshots_l5"
OUT_NAME = "PAM_L5_NichitaOrmanji"


def img(name: str) -> str:
    data = base64.b64encode((SHOTS / name).read_bytes()).decode()
    return f'<img class="shot" src="data:image/png;base64,{data}" alt="{name}">'


def shots(*items: tuple[str, str]) -> str:
    cells = "".join(
        f"<figure>{img(n)}<figcaption>{html.escape(c)}</figcaption></figure>"
        for n, c in items
    )
    return f'<div class="shots">{cells}</div>'


def table(header, rows) -> str:
    th = "".join(f"<th>{h}</th>" for h in header)
    trs = "".join(
        "<tr>" + "".join(f"<td>{html.escape(c)}</td>" for c in r) + "</tr>"
        for r in rows
    )
    return f'<table class="small-table"><tr>{th}</tr>{trs}</table>'


def snip(path: str, start: str, end: str) -> str:
    return base.snippet(path, start, end)


def text_file(name: str) -> str:
    """Вывод терминала, сохранённый в docs/report, — как блок кода."""
    text = (base.REPORT / name).read_text(encoding="utf-8").strip()
    return f'<pre class="code term"><code>{html.escape(text)}</code></pre>'


def git(*args: str) -> str:
    out = subprocess.run(
        ["git", *args], cwd=base.ROOT, capture_output=True, text=True,
        encoding="utf-8", check=True,
    ).stdout
    return out


ROUTES = [
    ("Записи дневника (Дневник + Скиния)", "entries", "GET/POST /entries (?page=&limit=&search=), GET/PUT/DELETE /entries/{id}"),
    ("«Мой день»", "day_plan, daily_tasks, task_done", "GET /plans/today, PATCH /plans/today/tasks/{id}"),
    ("«Вместе»", "reading_groups, group_members, group_leaves, feed", "GET /groups, DELETE /groups/{id}/membership, GET /feed"),
    ("Библия", "books, chapter_headings, verses, searches", "GET /books, GET /books/{id}/chapters/{n}, GET /search?q=, GET /me/searches"),
    ("Профиль", "profiles (+ name/email из users)", "GET/PUT /profile (базовый GET /me не тронут)"),
]

TASKS = [
    ("1. Сервер", "Порт шаблона на Dart скопирован в server/, запущен (/health → ok), контракт исследован curl-ом: 401, 201 + token, 409, пустой конверт, 201 с id от сервера, поиск, 404 на чужое."),
    ("2. Сущности темы", "5 сущностей Bibly: таблицы в db.dart, модули по образцу notes.dart, маршруты под requireAuth; справочные данные — seed.dart; по коммиту на сущность."),
    ("3. Настоящий вход", "http + shared_preferences; TokenStore, apiMessage, AuthApi; форма входа с режимом регистрации и _busy; запуск решает по token-у; logout в профиле."),
    ("4. Http-хранилища", "fromJson/toJson у сущностей; ApiClient с тремя слоями отказа и потоком 401; 5 Http*Repository на интерфейсах ЛР4, интерфейсы не изменены."),
    ("5. Замена в корне", "main.dart передаёт http-хранилища; mock-и и seed ушли из lib/ (git mv в test/fakes); переключатель аварии удалён; git diff — экраны/модели не тронуты."),
    ("6. Страницы и поиск", "fetchAll({page, limit, search}) — совместимо; DiaryModel.load(search:)/loadMore() с guard; поле поиска и хвост списка в Дневнике."),
    ("7. Upload", "Не требуется темой (у сущностей нет файлов) — пропущено без штрафа; POST /files шаблона работает (проверено smoke-тестом)."),
]

PROBLEMS = [
    ("В dart.zip на ELSE нет набора conformance/ и openapi.yaml (README сервера ссылается на них уровнем выше).",
     "Базовый контракт и маршруты Bibly проверены собственным smoke-тестом на чистой базе: PASS 48/48. Прогон conformance добавлю, когда набор будет получен от преподавателя."),
    ("Windows: package:sqlite3 требует sqlite3.dll.",
     "Копия из Python313\\DLLs положена рядом с сервером и добавлена в server/.gitignore."),
    ("curl в Git Bash кодирует кириллицу в cp1251 → сервер отвечает 400.",
     "Запрос с UTF-8 кодировкой (%D0%9F…) работает; приложение кодирует URL в UTF-8 само — это особенность консоли."),
    ("SQLite LIKE/lower() не учитывают регистр только для латиницы: «НИКОДИМ» не находил «Никодим».",
     "Колонка search_text в нижнем регистре (toLowerCase() в Dart); поиск стихов фильтруется в Dart."),
    ("Поиск «Ин 3:16» находил и «Ин 3:1» (основа «ин » совпала с «один из»).",
     "Запрос с цифрами считается ссылкой и ищется только по ссылке."),
    ("Android 9+ блокирует http://, а INTERNET было только в debug-манифесте.",
     "В основной манифест: uses-permission INTERNET и android:usesCleartextTraffic=\"true\" (лабораторный сервер без TLS)."),
    ("Сервер не пишет charset — пакет http прочёл бы res.body как latin1 («Ð Ð¾Ð´…»).",
     "Тело декодируется явно: jsonDecode(utf8.decode(res.bodyBytes)); на это есть тест."),
    ("Модели создаются один раз: после выхода и входа другим пользователем остались бы чужие данные, после 401 — старые ошибки.",
     "AuthApi.session (ValueNotifier) растёт при входе; MultiProvider моделей с key: ValueKey(session) — модели создаются заново. Модели и экраны не тронуты."),
    ("Виджет-тесты без сервера.",
     "FakeAuthApi и testApp() в test/fakes — тот же createApp, но на дублёрах в памяти."),
    ("adb input text не вводит кириллицу.",
     "Записи с кириллицей созданы через API; в приложении — транслит; поиск показан по ссылке «4:4»."),
]

EXTRA_CSS = """
.shots { gap: 4mm; }
img.shot { width: 39mm; }
figure { margin: 0; text-align: center; }
figcaption { font-size: 9pt; color: #444; margin-top: 2pt; max-width: 39mm; }
.small-table { font-size: 10pt; }
img.diagram { width: 100%; border: 1px solid #ddd; border-radius: 3mm; }
pre.term { font-size: 8.5pt; white-space: pre-wrap; word-break: break-all; }
.note { background: #FFF8E1; border-left: 3pt solid #F9A825; padding: 4pt 8pt; }
"""


def build_html() -> str:
    t = dict(base.TITLE)
    t["work"] = "Лабораторная работа № 5"
    t["work_title"] = "Интеграция с собственным backend-ом"
    svg = (base.REPORT / "architecture_l5.svg").read_text(encoding="utf-8")
    svg_b64 = base64.b64encode(svg.encode("utf-8")).decode()
    git_log = git("log", "--oneline")
    server_log = git("log", "--oneline", "--", "server")

    p = [f"""<!doctype html><html lang="ru"><head><meta charset="utf-8">
<title>{OUT_NAME}</title><style>{base.CSS}{EXTRA_CSS}</style></head><body>
<div class="title">
  <div class="top">{t['university']}<br>{t['faculty']}<br>{t['department']}</div>
  <div class="mid">
    <div>Дисциплина: {t['discipline']}</div>
    <div class="w" style="margin-top:14pt">{t['work']}</div>
    <div class="t">{t['work_title']}</div>
    <div class="th">{t['theme']}</div>
  </div>
  <div class="who">
    Студент: {t['student']}, гр. {t['group']}<br>
    Преподаватель: {t['teacher']}<br>Учебный год: {t['year']}
  </div>
  <div class="city">{t['city']}</div>
</div>"""]

    p.append(f"""<h1>1. Тема и что сделано</h1>
<p><b>{html.escape(t['theme'])}.</b> ЛР5 продолжает проект ЛР4 в той же истории Git.
Приложение получило собственный сервер: backend-шаблон курса (порт на <b>Dart</b> — язык уже
установлен вместе с Flutter, приложение и сервер на одном языке), расширенный сущностями темы.
Вход стал настоящим (JWT token в <code>shared_preferences</code>), mock-хранилища ЛР4 заменены
http-реализациями <b>только в корне композиции</b>, пагинация и поиск выполняются на сервере.</p>
{table(["Задание", "Что сделано"], TASKS)}
<p><b>Что ЛР5 не делает</b> (контракт работы): offline-кэша нет — при остановленном сервере
приложение показывает экран ошибки, а не вчерашние данные (локальное хранение — ЛР6);
CORS открыт, секрет JWT по умолчанию, prefs не зашифрованы — лабораторная конфигурация;
сервер работает на ноутбуке, эмулятор обращается к нему по <code>http://10.0.2.2:8080</code>.</p>

<h1>2. Архитектура</h1>
<p>Диаграмма ЛР4 с заменённым mock-ом: экраны → модели → интерфейсы →
<code>Http*Repository</code> → сервер. Оранжевым — путь token-а, красным — путь 401.</p>
<img class="diagram" src="data:image/svg+xml;base64,{svg_b64}" alt="architecture">
<p class="note"><b>Что не пришлось менять и почему:</b> экраны и модели не узнали о переходе
на сервер, потому что зависят только от интерфейсов хранилищ и <code>Result</code>, а выбор
реализации живёт в одном месте — корне композиции <code>main.dart</code>.</p>

<h1>3. Backend: сущности темы и проверка контракта</h1>
<h2>Маршруты, добавленные для темы</h2>
<p>Для каждой сущности: <code>CREATE TABLE IF NOT EXISTS</code> в <code>server/lib/db.dart</code>,
модуль по образцу <code>notes.dart</code> (список с пагинацией и поиском, создание с валидацией
400, get/put/delete с 404 на чужое), маршруты рядом с <code>/notes</code> под тем же
<code>requireAuth</code>. Справочные данные (книги, стихи, план дня, группы, лента) —
<code>server/lib/seed.dart</code>, <code>INSERT OR IGNORE</code> с постоянными id.</p>
{table(["Сущность", "Таблицы", "Маршруты"], ROUTES)}
<h2>Проверка соответствия</h2>
<p class="note">Набор <code>conformance/</code> из kit-а на ELSE не выложен: в курсе FCIM.PAM21.2,
папка «PAM - BackEnd (project example)», — только архивы портов (dart, dotnet, go, java,
node, python, rust), без <code>conformance/</code> и <code>openapi.yaml</code>. Поэтому базовый
контракт шаблона и все маршруты Bibly проверены собственным smoke-тестом на чистой базе
(<code>app.db</code> удалён перед прогоном). Прогон conformance будет добавлен, когда набор
будет получен.</p>
{text_file("api_check_l5.txt")}

<h1>4. Сессия curl на сущности темы</h1>
<p>Register → 401 без token-а → создание (id даёт сервер) → 400 без заголовка → список
(пагинированный конверт) → поиск на сервере → вторая страница. Token заменён на
<code>eyJ...</code>.</p>
{text_file("curl_l5_entries.txt")}

<h1>5. Настоящий вход: token в shared_preferences</h1>
<p>Поток token-а: <code>AuthApi.login/register</code> → <code>TokenStore.save</code>
(<code>setString</code>) → при запуске <code>main()</code> читает token
(<code>getString</code>) и строит router со стартом <code>/day</code> или <code>/login</code> →
каждый запрос <code>ApiClient</code> ставит <code>Authorization: Bearer</code> → logout и 401
вызывают <code>TokenStore.clear</code> (<code>remove</code>). <b>Пароль не хранится нигде.</b></p>
{shots(("01_register_form.png", "регистрация: поле «Имя»"), ("02_after_register.png", "201 → приложение"), ("03_reopen_logged_in.png", "kill + запуск: сразу «Мой день»"), ("05_wrong_password.png", "401 → «Неверный email или пароль»"))}
{text_file("prefs_token_l5.txt")}
{snip("lib/data/token_store.dart", "class TokenStore {", "    await prefs.remove(_key);\n  }\n}")}
{snip("lib/screens/login_screen.dart", "  Future<void> _submit() async {", "            .showSnackBar(SnackBar(content: Text(msg)));\n    }\n  }")}

<h1>6. Ключевой код</h1>
<h2>Три слоя отказа и перевод конверта — общий скелет запроса</h2>
<p>Каждый метод хранилища — «адрес + хороший статус + разбор»; скелет запроса написан один
раз в <code>ApiClient._send</code>. Упавшая дорога бросает и ловится по типам
(<code>.timeout</code> на каждом запросе), дурная весть сервера читается через
<code>statusCode</code> и переводится <code>apiMessage</code>, тело-сюрприз падает при
разборе. Всё сходится в <code>Err(msg)</code>; общего <code>catch (e)</code> нет.</p>
{snip("lib/data/http/api_client.dart", "  Future<Result<T>> _send<T>(", "      return const Err('Ответ не тот, что обещан');\n    }\n  }")}
{snip("lib/data/api_message.dart", "String apiMessage(http.Response res) {", "    return 'Ошибка сервера (${res.statusCode})'; // JSON, но не конверт\n  }\n}")}
<h2>Http-хранилище дневника на интерфейсе ЛР4</h2>
{base.code("lib/data/http/http_diary_repository.dart")}
{snip("lib/models/diary_entry.dart", "  factory DiaryEntry.fromJson", "    'isPrivate': isPrivate,\n  };")}
<h2>Поток 401</h2>
<p>Хранилище не импортирует router: оно стирает token и зовёт callback, а куда идти, решает
корень.</p>
{snip("lib/data/http/api_client.dart", "  /// 401 = пропуск умер", "    return 'Сессия истекла — войдите снова';\n  }")}
{snip("lib/main.dart", "  // ЛР5: источник данных — сервер.", "      profile: HttpProfileRepository(api),\n    ),\n  );\n}")}

<h1>7. Приложение против настоящего сервера</h1>
<p>Список грузится с сервера (у нового пользователя «0 дней», «0 из 4» — не mock-овые
«12 дней»), форма создаёт запись через <code>POST</code> (id от сервера: 14), удаление —
<code>DELETE → 204</code> без разбора пустого тела.</p>
{shots(("06_my_day_from_server.png", "«Мой день» с сервера"), ("07_diary_from_server.png", "Дневник с сервера"), ("08_created_on_server.png", "создана: POST 201, id 14"))}
<h2>Три состояния на настоящей сети и 401</h2>
<p>Сервер остановлен → экран ошибки с сетевым сообщением, без crash-а; запущен →
«Повторить» → данные вернулись (отметка плана сохранилась на сервере). Сервер перезапущен
с <code>JWT_SECRET=alt-secret</code> → первый запрос получил 401 → token стёрт из prefs
(<code>&lt;map /&gt;</code>) → приложение само на экране входа; после входа всё грузится
заново.</p>
{shots(("09_server_stopped_error.png", "сервер остановлен"), ("10_after_retry.png", "запущен → «Повторить»"), ("11_401_back_to_login.png", "401 → вход"), ("12_relogin_together.png", "повторный вход"))}

<h1>8. Пагинация и поиск на сервере</h1>
<p>Интерфейс вырос совместимо: <code>fetchAll({{int page = 1, int limit = 20, String? search}})</code>
— старый вызов <code>fetchAll()</code> компилируется без изменений. Последний элемент
<code>ListView.builder</code> вызывает <code>loadMore()</code> и показывает spinner;
<code>_loadingMore</code> ставится без извещения (вызов идёт в разгар build), guard не даёт
задублировать страницу. Задание 5 доказало, что смена источника не тронула экраны; Задание 6
их трогает — ради новой функциональности. У пользователя на сервере 25 записей.</p>
{shots(("13_diary_page1.png", "page=1: 20 записей"), ("14_diary_page2.png", "хвост → page=2: ещё 5"), ("15_server_search.png", "search=4:4 → 2 записи"))}
{text_file("server_log_task6_l5.txt")}
{snip("lib/models/diary_model.dart", "  Future<void> loadMore() async {", "    _loadingMore = false;\n    notifyListeners();\n  }")}

<h1>9. Тесты</h1>
<p><code>flutter analyze</code> — без замечаний; <code>flutter test</code> — 51 тест проходит,
5 «живых» пропускаются без сервера. Http-хранилища проверены подменой «провода»
(<code>MockClient</code> через <code>http.runWithClient</code>, код хранилищ настоящий) и
против настоящего сервера (<code>--dart-define=BIBLY_SERVER=http://localhost:8080</code>):</p>
{text_file("http_tests_l5.txt")}

<h1>10. Доказательство Git</h1>
<h2>Что изменилось по сравнению с защитой ЛР4 (7e385c6)</h2>
<p>Легитимные исключения: <code>login_screen.dart</code> (связан с сервером — обещано на ЛР4)
и <code>profile_screen.dart</code> (logout стирает token, переключатель аварии удалён).
Файлы сущностей выросли на <code>fromJson/toJson</code> (Задание 4). Ни одной
ChangeNotifier-модели и ни одного экрана с данными в списке нет. Вывод снят после
Задания 5 — Задание 6 сознательно меняет Дневник и DiaryModel ради новой функциональности.</p>
{text_file("git_diff_l5.txt")}
<h2>Коммиты сервера (server/)</h2>
<pre class="code"><code>{html.escape(server_log)}</code></pre>
<h2>Полный git log --oneline — от ЛР2 до сегодня</h2>
<pre class="code"><code>{html.escape(git_log)}</code></pre>

<h1>11. Проблемы и их решение</h1>
{table(["Проблема", "Решение"], PROBLEMS)}
</body></html>""")
    return "\n".join(p)


def main() -> None:
    out_html = base.REPORT / f"{OUT_NAME}.html"
    out_pdf = base.REPORT / f"{OUT_NAME}.pdf"
    out_html.write_text(build_html(), encoding="utf-8")
    subprocess.run(
        [str(base.EDGE), "--headless", "--disable-gpu", "--no-pdf-header-footer",
         f"--print-to-pdf={out_pdf}", out_html.as_uri()],
        check=True,
    )
    print(f"PDF: {out_pdf}")


if __name__ == "__main__":
    main()
