"""Сборка отчёта по ЛР4 в PDF.

Запуск из корня проекта:  python docs/report/build_report_l4.py
Результат: docs/report/PAM_L4_NichitaOrmanji.pdf (и .html рядом).

Титульный лист, стили, вставка кода и git log — общие с ЛР2
(build_report.py, словарь TITLE: группа, номер темы).
"""

import base64
import html
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import build_report as base  # noqa: E402

SHOTS = base.REPORT / "screenshots_l4"
OUT_NAME = "PAM_L4_NichitaOrmanji"


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


STATE_TABLE = [
    ("Отметки плана дня", "DayPlanModel", "прогресс в «Моём дне» + бейдж «осталось N» на вкладке"),
    ("Записи дневника — главная сущность (CRUD)", "DiaryModel", "Дневник, Скиния, запись, поиск «Мой дневник», счётчик в профиле"),
    ("Книги, главы, поиск, недавние запросы", "BibleModel", "Библия, Книга, Глава, Поиск, валидатор ссылки на стих"),
    ("Группы и лента", "CommunityModel", "Вместе, Группа"),
    ("Профиль пользователя", "ProfileModel", "Профиль, приветствие в «Моём дне», «Продолжить чтение», форма профиля"),
    ("«Показать пароль», выбор в Dropdown, фильтр поиска, «Сохраняем…», переключатель аварии, текст в полях", "setState в State", "эфемерное: нужно одному экрану, не переживает уход с него"),
]

LAYERS = [
    ("Экраны (lib/screens)", "Показывают модели (watch в build), действуют через read в callback-ах; на каждом экране с данными — грузится / ошибка + «Повторить» / данные.", "Не меняются."),
    ("Модели (lib/models/*_model.dart)", "ChangeNotifier: состояние темы и логика; коллекции наружу только для чтения; каждая мутация — notifyListeners(); хранилище приходит через конструктор.", "Не меняются."),
    ("Интерфейсы (lib/data/*_repository.dart)", "Контракт: что можно просить. Каждый метод — Future<Result<T>>; в комментарии указан будущий REST-эндпоинт.", "Не меняются (контракт уже совпадает с REST)."),
    ("Mock-реализации (lib/data/mock)", "Память + seed из mock_data.dart, Future.delayed(800 мс), общий флаг аварии MockNetwork.simulateError.", "Заменяются Http-реализациями; mock_data.dart и переключатель аварии удаляются."),
    ("Корень композиции (main.dart)", "createApp(): создаёт хранилища (переменные с типом интерфейса) и монтирует модели в MultiProvider фабрикой с ..load().", "Меняются строки создания хранилищ."),
]

PROBLEMS = [
    ("Бейдж на вкладке пропадал, когда вкладка выбрана.", "У NavigationDestination показывается selectedIcon — бейдж-Consumer вынесен в виджет _PlanBadge и обёрнут вокруг обеих иконок."),
    ("Тесты «зависали» на ожидании: pumpAndSettle не ждёт задержку mock-а, если нет анимации.", "Помощник waitNetwork(): pump(1 с) + pumpAndSettle."),
    ("Фильтр «Мой дневник» в поиске загружал данные молча (тест: Timer is still pending).", "Ветке фильтра добавлена своя триада DiaryModel: спиннер / ErrorView / данные."),
    ("Три состояния нельзя было показать на Дневнике: профиль загружает DiaryModel раньше, чем включается авария.", "В Дневник добавлено обновление свайпом вниз (RefreshIndicator → DiaryModel.load())."),
    ("adb input text не вводит кириллицу.", "Заголовок записи на скриншотах набран транслитом."),
]

EXTRA_CSS = """
.shots { gap: 4mm; }
img.shot { width: 39mm; }
figure { margin: 0; text-align: center; }
figcaption { font-size: 9pt; color: #444; margin-top: 2pt; max-width: 39mm; }
.small-table { font-size: 10pt; }
img.diagram { width: 100%; border: 1px solid #ddd; border-radius: 3mm; }
"""


def build_html() -> str:
    t = dict(base.TITLE)
    t["work"] = "Лабораторная работа № 4"
    t["work_title"] = "State management и паттерн Repository с mock-данными"
    svg = (base.REPORT / "architecture_l4.svg").read_text(encoding="utf-8")
    svg_b64 = base64.b64encode(svg.encode("utf-8")).decode()

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
<p><b>{html.escape(t['theme'])}.</b> ЛР4 продолжает проект ЛР3: первый коммит —
<code>flutter pub add provider</code> (<code>provider: ^6.1.5+1</code>). Приложение получило
разделяемое состояние на <code>ChangeNotifier</code> + <code>provider</code> и слой хранилищ
(паттерн Repository) с mock-реализацией: задержка 800 мс и переключаемая авария.
Все экраны с данными показывают три состояния, мутации и формы пишут через модели в хранилище,
и изменение сразу видно на всех подписанных экранах. Закрыли приложение — состояние пропадает:
это контракт ЛР4 (сохранение на устройстве — ЛР6). Вход остаётся локальной валидацией (ЛР5).</p>
<h2>Что разделяемое, а что эфемерное</h2>
{table(["Состояние", "Где живёт", "Кто читает / почему"], STATE_TABLE)}

<h1>2. Архитектура</h1>
<p>Диаграмма нарисована для этого проекта: экраны → модели → интерфейсы → mock,
со стрелками watch/read, notifyListeners и <code>Future&lt;Result&lt;T&gt;&gt;</code>.</p>
<img class="diagram" src="data:image/svg+xml;base64,{svg_b64}" alt="architecture">
<h2>Слои и что меняется на ЛР5</h2>
{table(["Слой", "Что делает", "На ЛР5"], LAYERS)}
<p><b>Вопрос защиты: «завтра mock становится backend-ом — какие файлы вы трогаете?»</b>
Новые реализации хранилищ (<code>Http*Repository</code>) и корень композиции в
<code>main.dart</code>; ни одного экрана и ни одной модели — кроме переключателя аварии в
профиле, который исчезает вместе с mock-ом.</p>
<p><b>Чистая архитектура.</b> <code>grep -rn "mock_data\\|mockRecords" lib/screens lib/widgets lib/models</code>
→ пусто (проверено и для <code>lib/utils</code>, <code>router.dart</code>, <code>main.dart</code>).
<code>mock_data.dart</code> импортируют только 5 файлов <code>lib/data/mock/mock_*_repository.dart</code>.</p>

<h1>3. Ключевой код</h1>
<h2>Вердикт и интерфейс главной сущности</h2>
{base.code("lib/data/result.dart")}
{base.code("lib/data/diary_repository.dart")}
<h2>Метод mock-а: create — задержка, авария, id даёт хранилище</h2>
{snip("lib/data/mock/mock_network.dart", "  /// Пролог каждого метода", "    return !simulateError;\n  }")}
{snip("lib/data/mock/mock_diary_repository.dart", "  @override\n  Future<Result<DiaryEntry>> create", "    return Ok(created);\n  }")}
<h2>Модель: DI через конструктор, load() с триадой, мутация add()</h2>
{snip("lib/models/diary_model.dart", "class DiaryModel extends ChangeNotifier {", "  List<DiaryEntry> get entries => List.unmodifiable(_entries);")}
{snip("lib/models/diary_model.dart", "  Future<void> load() async {", "    _loading = false;\n    notifyListeners();\n  }")}
{snip("lib/models/diary_model.dart", "  Future<String?> add(DiaryEntry draft) async {", "        return msg;\n    }\n  }")}
<h2>Корень композиции</h2>
{snip("lib/main.dart", "Widget createApp() {", "  );\n}")}
<h2>watch / read / Consumer</h2>
{snip("lib/widgets/app_shell.dart", "class _PlanBadge extends StatelessWidget {", "      child: child,\n    );\n  }\n}")}
{snip("lib/screens/new_entry_screen.dart", "  Future<void> _save() async {", "    context.pop(); // список позади УЖЕ обновлён — без единого лишнего вызова\n  }")}

<h1>4. Три состояния главного экрана</h1>
<p>«Дневник»: <code>watch&lt;DiaryModel&gt;()</code> в build → <code>isLoading</code> — спиннер,
<code>error</code> — <code>ErrorView</code> с сообщением из <code>Err</code> и «Повторить»
(<code>read&lt;DiaryModel&gt;().load()</code>), иначе — список. Ошибка спровоцирована
переключателем «Симулировать сбой сети» в профиле; приложение не падает.</p>
{shots(("30_crash_switch_on.png", "авария включена"), ("11_diary_error.png", "ошибка + «Повторить»"), ("10_diary_loading.png", "«Повторить» → грузится"), ("12_diary_data.png", "авария выкл. → данные"))}

<h1>5. Мультиэкранная мутация</h1>
<h2>Удаление записи: детали → список → профиль</h2>
<p>Диалог из ЛР3 получил эффект: <code>DiaryModel.remove(id)</code> → хранилище →
<code>notifyListeners()</code>. Запись исчезла из списка («Мои записи» 7 → 6), а счётчик в
профиле 13 → 12 — никто ничего не перезагружал. Свайп по карточке
(<code>Dismissible</code> с <code>ValueKey(entry.id)</code>) удаляет так же.</p>
{shots(("20_profile_before_13.png", "до: профиль, 13 записей"), ("21_entry_before_delete.png", "до: детали записи"), ("22_diary_after_delete.png", "после: записи нет в списке"), ("23_profile_after_12.png", "после: профиль, 12"))}
<h2>Отметка плана: прогресс и бейдж на вкладке</h2>
{shots(("24_day_before_toggle.png", "до: 2 из 4, бейдж 2"), ("25_day_after_toggle.png", "после: 3 из 4, бейдж 1"))}

<h1>6. Связанная форма</h1>
<p>Валидация ЛР3 не тронута; <code>_save</code> собирает черновик (<code>id: 0</code> —
настоящий даст хранилище) и пишет через <code>DiaryModel.add</code>. После <code>pop()</code>
список уже вырос. При включённой аварии — SnackBar с ошибкой, данные остаются в полях.</p>
{shots(("31_form_filled.png", "заполненная форма"), ("33_form_crash_snackbar.png", "авария: ошибка, поля целы"), ("32_form_saved_list_grown.png", "сохранено: список вырос 6 → 7"))}

<h1>7. Проблемы и их решение</h1>
{table(["Проблема", "Решение"], PROBLEMS)}
<p>Проверка: <code>flutter analyze</code> — без замечаний; 28 тестов: хранилища (id от хранилища,
«404», авария), модели (read-only коллекции, notifyListeners на входе и выходе из загрузки,
ошибка не меняет состояние), виджеты (бейдж, удаление видно на нескольких экранах, форма
расширяет список, смена имени меняет приветствие, переключатель аварии).</p>

<h1>8. История Git</h1>
<p>Вывод <code>git log --oneline</code> полностью — от ЛР2 до сегодня:</p>
{base.git_log()}
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
