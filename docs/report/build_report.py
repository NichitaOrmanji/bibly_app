"""Сборка отчёта по ЛР2 в PDF.

Запуск из корня проекта:  python docs/report/build_report.py
Результат: docs/report/PAM_L2_NichitaOrmanji.pdf (и .html рядом).

Поля титульного листа — в блоке TITLE ниже: поправьте и запустите снова.
"""

import base64
import html
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REPORT = ROOT / "docs" / "report"
SHOTS = REPORT / "screenshots"
OUT_NAME = "PAM_L2_NichitaOrmanji"

EDGE = Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")

# ---------- Титульный лист: проверьте и заполните ----------
TITLE = {
    "university": "Технический университет Молдовы",
    "faculty": "Факультет вычислительной техники, информатики и микроэлектроники",
    "department": "Департамент программной инженерии и автоматики",
    "discipline": "Программирование мобильных приложений (PAM)",
    "work": "Лабораторная работа № 2",
    "work_title": "Статический UI приложения: экраны темы в Material 3",
    "student": "Орманжи Никита",
    "group": "________",  # <-- впишите группу
    "teacher": "унив. лектор Ionel Antohi",
    "year": "2026–2027",
    "city": "Кишинёв, 2026",
    # Номер и название темы из каталога
    "theme": "Тема № ___ — Bibly: ежедневное чтение Библии, дневник и совместное чтение",
}


def img(name: str, cls: str = "shot") -> str:
    data = base64.b64encode((SHOTS / name).read_bytes()).decode()
    return f'<img class="{cls}" src="data:image/png;base64,{data}" alt="{name}">'


def code(path: str) -> str:
    text = (ROOT / path).read_text(encoding="utf-8")
    return f'<pre class="code"><code>{html.escape(text)}</code></pre>'


def snippet(path: str, start: str, end: str) -> str:
    text = (ROOT / path).read_text(encoding="utf-8")
    i = text.index(start)
    j = text.index(end, i) + len(end)
    return f'<pre class="code"><code>{html.escape(text[i:j])}</code></pre>'


def git_log() -> str:
    out = subprocess.run(
        ["git", "log", "--oneline"],
        cwd=ROOT, capture_output=True, text=True, encoding="utf-8", check=True,
    ).stdout
    return f'<pre class="code"><code>{html.escape(out)}</code></pre>'


# ---------- Экраны: порядок по списку темы ----------
SCREENS = [
    ("Вход", ["01_login_android.png"],
     "Статический экран входа: логотип, два <code>TextField</code> (e-mail и пароль с "
     "<code>obscureText: true</code>) и <code>FilledButton</code> «Войти». Без <code>Form</code>, "
     "без валидации: кнопка только переходит в приложение. Файл <code>login_screen.dart</code>."),
    ("Мой день", ["21_my_day_final_android.png", "10_my_day_4_steps_android.png"],
     "Главный экран: приветствие, серия дней (<code>Chip</code>), «Стих дня» "
     "(<code>VerseCard</code>) и план из 4 шагов — цитата, отрывок из Библии, размышление, "
     "призыв к молитве (<code>DailyTaskTile</code> + <code>LinearProgressIndicator</code>). "
     "Отрывок открывает «Чтение главы», лупа — «Поиск». Файл <code>my_day_screen.dart</code>."),
    ("Библия — список книг", ["05_bible_android.png", "22_bible_nt_final_android.png"],
     "Карточка «Продолжить чтение» и все 66 книг синодального порядка с числом глав, "
     "разделённые на Ветхий и Новый Завет. <code>ListView.builder</code> строит строки "
     "<code>BookTile</code> лениво, заголовки заветов — <code>SectionHeader</code>. "
     "Файл <code>bible_screen.dart</code>."),
    ("Чтение главы", ["11_chapter_android.png", "12_chapter_highlight_android.png"],
     "Текст главы (Ин 3, Синодальный перевод) по стихам — виджет <code>VerseLine</code> на "
     "основе <code>Text.rich</code>; выделенный стих 16 подсвечен фоном "
     "<code>tertiaryContainer</code>. Внизу — переход к соседним главам и «В дневник». "
     "Файл <code>chapter_screen.dart</code>."),
    ("Поиск", ["17_search_android.png"],
     "Поле поиска (<code>TextFormField</code> без <code>Form</code>), фильтры "
     "<code>FilterChip</code>, недавние запросы <code>ActionChip</code> и 7 результатов по "
     "запросу «любовь» в <code>ListView.separated</code> с <code>VerseCard</code>. "
     "Фильтры — визуальные, заработают в ЛР4. Файл <code>search_screen.dart</code>."),
    ("Вместе", ["15_together_android.png", "16_together_feed_android.png"],
     "Группы совместного чтения в горизонтальном <code>ListView.separated</code> (план, "
     "прогресс, участники) и лента друзей: прогресс, общие записи дневника, просьбы о "
     "молитве с кнопкой «Помолюсь». Аватары — <code>InitialsAvatar</code>. "
     "Файл <code>together_screen.dart</code>."),
    ("Дневник", ["07_diary_android.png"],
     "Обычные записи дневника (<code>DiaryEntryCard</code>: дата, заголовок, текст, ссылка "
     "на стих), карточка входа в «Скинию» и кнопка «Новая запись» "
     "(<code>FloatingActionButton.extended</code>). Файл <code>diary_screen.dart</code>."),
    ("Скиния — личные записи по паролю", ["08_tabernacle_lock_android.png", "09_tabernacle_android.png"],
     "Приватный раздел дневника. Экран пароля статический (поле + «Открыть», без проверки), "
     "затем список личных записей с тем же <code>DiaryEntryCard</code>. Файлы "
     "<code>tabernacle_lock_screen.dart</code> и <code>tabernacle_screen.dart</code>."),
    ("Профиль / настройки", ["13_profile_android.png", "14_profile_settings_android.png"],
     "Аватар с инициалами, статистика из трёх <code>StatTile</code>, 8 пунктов настроек "
     "(<code>ListTile</code>, статические <code>Switch</code>) и кнопка «Выйти», "
     "возвращающая на экран входа. Файл <code>profile_screen.dart</code>."),
]

WIDGETS = [
    ("SectionHeader", "lib/widgets/section_header.dart",
     "Мой день, Библия, Дневник, Вместе, Профиль"),
    ("VerseCard", "lib/widgets/verse_card.dart",
     "Мой день (стих дня), Поиск (7 результатов)"),
    ("DailyTaskTile", "lib/widgets/daily_task_tile.dart", "Мой день (4 шага плана)"),
    ("BookTile", "lib/widgets/book_tile.dart", "Библия (66 книг)"),
    ("DiaryEntryCard", "lib/widgets/diary_entry_card.dart", "Дневник, Скиния"),
    ("InitialsAvatar", "lib/widgets/initials_avatar.dart",
     "Профиль (аватар пользователя), Вместе (лента друзей)"),
    ("StatTile", "lib/widgets/stat_tile.dart", "Профиль (3 плитки статистики)"),
    ("VerseLine", "lib/widgets/verse_line.dart", "Чтение главы (каждый стих)"),
]

LIB_TREE = """lib/
├── main.dart          # MaterialApp: светлая и тёмная тема, стартовый экран — вход
├── screens/           # по одному файлу на экран + оболочка с NavigationBar
│   ├── login_screen.dart
│   ├── main_shell.dart          # NavigationBar на 5 вкладок (хранит только индекс)
│   ├── my_day_screen.dart
│   ├── bible_screen.dart
│   ├── chapter_screen.dart
│   ├── search_screen.dart
│   ├── diary_screen.dart
│   ├── tabernacle_lock_screen.dart
│   ├── tabernacle_screen.dart
│   ├── together_screen.dart
│   └── profile_screen.dart
├── widgets/           # переиспользуемые виджеты
│   ├── section_header.dart   ├── verse_card.dart
│   ├── daily_task_tile.dart  ├── book_tile.dart
│   ├── diary_entry_card.dart ├── initials_avatar.dart
│   ├── stat_tile.dart        └── verse_line.dart
├── models/            # классы данных: книга, стих, стих главы, пункт плана,
│                      # запись дневника, группа и событие ленты
├── data/
│   └── mock_data.dart # статические данные, общие для нескольких экранов
└── utils/
    ├── app_theme.dart     # ThemeData из seed-цвета (светлая и тёмная)
    └── app_constants.dart # отступы и скругления"""

CSS = """
@page { size: A4; margin: 18mm 16mm; }
body { font-family: 'Times New Roman', serif; font-size: 12pt; line-height: 1.4; color: #111; }
h1 { font-size: 17pt; margin: 0 0 10pt; page-break-before: always; }
h2 { font-size: 14pt; margin: 14pt 0 6pt; }
p { margin: 4pt 0; text-align: justify; }
code { font-family: Consolas, monospace; font-size: 10pt; }
pre.code { font-family: Consolas, monospace; font-size: 8.5pt; line-height: 1.25;
  background: #f4f5f8; border: 1px solid #d9dce3; padding: 6pt 8pt;
  white-space: pre-wrap; word-break: break-word; }
.title { height: 255mm; display: flex; flex-direction: column; text-align: center; }
.title .top { font-size: 13pt; line-height: 1.6; }
.title .mid { margin-top: 55mm; }
.title .mid .w { font-size: 20pt; font-weight: bold; }
.title .mid .t { font-size: 16pt; margin-top: 6pt; }
.title .mid .th { font-size: 13pt; margin-top: 18pt; font-style: italic; }
.title .who { margin-top: auto; margin-left: auto; text-align: left; font-size: 13pt; line-height: 1.8; }
.title .city { margin-top: 30mm; font-size: 13pt; }
.screen { page-break-inside: avoid; margin-bottom: 6pt; }
.shots { display: flex; gap: 10mm; justify-content: center; margin: 6pt 0; }
img.shot { width: 41mm; border: 1px solid #ccc; border-radius: 3mm; }
img.small { width: 48mm; border: 1px solid #ccc; border-radius: 3mm; }
table { border-collapse: collapse; width: 100%; font-size: 11pt; }
td, th { border: 1px solid #bbb; padding: 3pt 6pt; vertical-align: top; }
.widget { page-break-inside: avoid; }
"""


def build_html() -> str:
    t = TITLE
    parts = [f"""<!doctype html><html lang="ru"><head><meta charset="utf-8">
<title>{OUT_NAME}</title><style>{CSS}</style></head><body>
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

    theme_snip = snippet("lib/utils/app_theme.dart", "  /// Глубокий синий", "    );\n  }")
    parts.append(f"""<h1>1. Тема проекта</h1>
<p><b>{html.escape(t['theme'])}.</b> Bibly — приложение для тихого времени с Богом:
ежедневный план из четырёх шагов (цитата, отрывок из Библии, размышление, призыв к
молитве), чтение Библии по книгам и главам, поиск, дневник с обычными записями и
приватным разделом «Скиния» под паролем, совместное чтение с друзьями в группах.</p>
<p>На ЛР2 приложение — функционально-визуальный макет: все экраны выглядят как в
конечном продукте, но данные зашиты в код, а большинство кнопок пока без эффекта.
Навигация минимальная, только для демонстрации: <code>NavigationBar</code> на пять
вкладок (Мой день / Библия / Дневник / Вместе / Профиль) и <code>Navigator.push</code>
к второстепенным экранам. Приложение запускалось на эмуляторе Android
<b>Bibly_Phone</b> (Android 11, API 30).</p>

<h1>2. Структура проекта</h1>
<pre class="code"><code>{html.escape(LIB_TREE)}</code></pre>
<p><b>screens/</b> — по одному файлу на экран; все экраны — <code>StatelessWidget</code>,
кроме оболочки <code>MainShell</code>, которая хранит только индекс выбранной вкладки.
<b>widgets/</b> — переиспользуемые компоненты, параметризованные через конструктор.
<b>models/</b> — простые неизменяемые классы данных с <code>const</code>-конструкторами.
<b>data/</b> — <code>mock_data.dart</code> со статическими данными; данные, нужные одному
экрану (настройки профиля, фильтры поиска), лежат в файле этого экрана.
<b>utils/</b> — тема и константы отступов, чтобы не повторять числа в экранах.</p>

<h1>3. Визуальная тема</h1>
<p>Вся палитра выводится из одного seed-цвета через <code>ColorScheme.fromSeed</code>;
светлая и тёмная темы переключаются по настройке системы
(<code>themeMode: ThemeMode.system</code>).</p>
{theme_snip}
<p><b>Почему этот цвет.</b> Глубокий синий <code>#3949AB</code> — цвет вечернего неба:
он настраивает на спокойствие и сосредоточенность, что подходит приложению для чтения
Писания и молитвы, и не утомляет глаза при долгом чтении.</p>
<p>В экранах цвета не зашиты: везде используется
<code>Theme.of(context).colorScheme</code> (<code>primaryContainer</code>,
<code>secondaryContainer</code>, <code>surfaceContainerLow</code> и т. д.). Поэтому при
включении ночного режима на эмуляторе всё приложение перекрасилось без единой правки
в коде:</p>
<div class="shots">{img('18_dark_my_day_android.png','small')}{img('19_dark_bible_android.png','small')}{img('20_dark_together_android.png','small')}</div>
<p><b>Изображения.</b> Вместо картинок используются иконки Material и круглые аватары с
инициалами (<code>InitialsAvatar</code>): так не нужны файлы в <code>assets</code>, а цвета
по-прежнему берутся из темы.</p>
""")

    parts.append("<h1>4. Экраны</h1>")
    for i, (name, shots, text) in enumerate(SCREENS, 1):
        imgs = "".join(img(s) for s in shots)
        parts.append(f"""<div class="screen"><h2>4.{i}. {name}</h2>
<p>{text}</p><div class="shots">{imgs}</div></div>""")

    parts.append("""<h1>5. Переиспользуемые виджеты</h1>
<p>Все виджеты параметризуются через конструктор (отображаемый объект и при
необходимости <code>onTap</code>). Если изменить вид виджета в его файле, он меняется на
всех экранах, где используется.</p>
<table><tr><th>Виджет</th><th>Где используется</th></tr>""")
    for name, _, used in WIDGETS:
        parts.append(f"<tr><td><code>{name}</code></td><td>{used}</td></tr>")
    parts.append("</table>")
    for name, path, used in WIDGETS:
        parts.append(f"""<div class="widget"><h2>{name}</h2>
<p>Файл <code>{path}</code>. Используется: {used}.</p>{code(path)}</div>""")

    parts.append("""<h1>6. Проблемы и их решение</h1>
<table>
<tr><th>Проблема</th><th>Решение</th></tr>
<tr><td>Сборка APK падала: <code>Android sdkmanager did not install NDK 28.2.13676358</code>.</td>
<td>Flutter требует NDK (<code>ndkVersion = flutter.ndkVersion</code>). NDK установлен вручную через <code>sdkmanager</code>.</td></tr>
<tr><td><code>sdkmanager "ndk;28.2.13676358"</code> из PowerShell завершался успешно, но ничего не ставил.</td>
<td><code>cmd</code> разбивает аргумент по символу <code>;</code>. Вызов через <code>cmd /c</code> с экранированными кавычками.</td></tr>
<tr><td>Слабый ПК: эмуляторы с образом API 37 не загружались.</td>
<td>Создан лёгкий эмулятор Bibly_Phone: Android 11 (API 30), x86_64, 1,5 ГБ RAM.</td></tr>
<tr><td>На узком экране (тест 320×568) строка карточки во «Вместе» переполнялась на 105 px.</td>
<td><code>Row</code> без ограничения ширины: текст времени обёрнут в <code>Expanded</code> с <code>TextOverflow.ellipsis</code>.</td></tr>
<tr><td>Плитки статистики в «Профиле» были разной высоты из-за переноса подписи.</td>
<td>Подпись сокращена до одной строки.</td></tr>
</table>
<p>Каждый экран проверялся командой <code>flutter analyze</code> (без замечаний) и
виджет-тестами <code>flutter test</code> (10 тестов: переходы между экранами, отсутствие
переполнений на экране 320×568, склонение «глава/главы/глав», инициалы).</p>
""")

    parts.append(f"<h1>7. История Git</h1><p>Вывод <code>git log --oneline</code>:</p>{git_log()}")
    parts.append("</body></html>")
    return "\n".join(parts)


def main() -> None:
    out_html = REPORT / f"{OUT_NAME}.html"
    out_pdf = REPORT / f"{OUT_NAME}.pdf"
    out_html.write_text(build_html(), encoding="utf-8")
    subprocess.run(
        [str(EDGE), "--headless", "--disable-gpu", "--no-pdf-header-footer",
         f"--print-to-pdf={out_pdf}", out_html.as_uri()],
        check=True,
    )
    print(f"PDF: {out_pdf}")


if __name__ == "__main__":
    main()
