"""Сборка отчёта по ЛР3 в PDF.

Запуск из корня проекта:  python docs/report/build_report_l3.py
Результат: docs/report/PAM_L3_NichitaOrmanji.pdf (и .html рядом).

Титульный лист, стили, вставка кода и git log — общие с ЛР2
(build_report.py): группу и номер темы правьте там, в TITLE.
"""

import base64
import html
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import build_report as base  # noqa: E402

SHOTS = base.REPORT / "screenshots_l3"
OUT_NAME = "PAM_L3_NichitaOrmanji"


def img(name: str, cls: str = "shot") -> str:
    data = base64.b64encode((SHOTS / name).read_bytes()).decode()
    return f'<img class="{cls}" src="data:image/png;base64,{data}" alt="{name}">'


def shots(*items: tuple[str, str]) -> str:
    """Ряд скриншотов с подписями."""
    cells = "".join(
        f'<figure>{img(n)}<figcaption>{html.escape(c)}</figcaption></figure>'
        for n, c in items
    )
    return f'<div class="shots">{cells}</div>'


ROUTES = [
    ("/login", "LoginScreen", "старт (initialLocation)",
     "Вне shell-а — у входа нет вкладок. После проверки — go('/day'): вход уходит из стека."),
    ("/search", "SearchScreen", "push (лупа)",
     "Вне shell-а, на весь экран поверх вкладок; «зашёл и вернулся»."),
    ("/day", "MyDayScreen", "вкладка 0 (goBranch)",
     "Первая вкладка; сюда ведёт go после входа."),
    ("/bible", "BibleScreen", "вкладка 1", "Список 66 книг."),
    ("/bible/:bookId", "BookScreen", "push",
     "Главы книги; id книги в адресе, экран ищет книгу сам."),
    ("/bible/:bookId/:chapter", "ChapterScreen", "push; соседние главы — pushReplacement",
     "«Назад» ведёт к списку глав, а не по всем прочитанным главам."),
    ("/diary", "DiaryScreen", "вкладка 2", "Записи дневника."),
    ("/diary/new", "NewEntryScreen", "push (FAB); go из главы",
     "Форма. Из главы — go: переход в другой раздел. Стоит ПЕРЕД :id."),
    ("/diary/unlock", "TabernacleLockScreen", "push",
     "Пароль Скинии; после проверки — go('/diary/tabernacle'), экран пароля уходит из стека."),
    ("/diary/tabernacle", "TabernacleScreen", "go после пароля", "Личные записи."),
    ("/diary/tabernacle/:id", "EntryScreen", "push", "Личная запись по id."),
    ("/diary/:id", "EntryScreen", "push", "Запись дневника по id."),
    ("/together", "TogetherScreen", "вкладка 3", "Группы и лента."),
    ("/together/:groupId", "GroupScreen", "push", "Группа по id."),
    ("/profile", "ProfileScreen", "вкладка 4", "Профиль; «Выйти» → диалог → go('/login')."),
    ("/profile/edit", "ProfileEditScreen", "push (карандаш)", "Форма профиля; после сохранения pop()."),
]

RULES = [
    ("Вход", "E-mail", "не пусто; формат x@y.z", "Введите e-mail / Неверный формат e-mail", "emailAddress, next"),
    ("Вход", "Пароль", "не пусто; ≥ 6 символов", "Введите пароль / Минимум 6 символов", "obscureText, done"),
    ("Новая запись", "Заголовок", "не пусто; ≤ 60", "Заголовок обязателен / Не длиннее 60 символов", "next, maxLength 60"),
    ("Новая запись", "Ссылка на стих", "необязательно; формат «Ин 3:16»; книга существует; глава ≤ глав в книге",
     "Формат: «Ин 3:16» или «1 Кор 13» / Нет такой книги: «…» / В книге «От Иоанна» глав: 21", "next"),
    ("Новая запись", "Текст", "не пусто; ≥ 10 символов", "Напишите хотя бы пару слов / Минимум 10 символов", "multiline"),
    ("Новая запись", "Куда сохранить", "выбран пункт", "Выберите, куда сохранить запись", "DropdownButtonFormField"),
    ("Пароль Скинии", "Пароль", "не пусто; только цифры; 4–6", "Введите пароль Скинии / От 4 до 6 цифр",
     "number, digitsOnly, ≤ 6 (LengthLimiting), obscureText"),
    ("Профиль", "Имя", "не пусто; ≥ 2 букв", "Введите имя / Имя — минимум 2 буквы", "words, next"),
    ("Профиль", "E-mail", "как во входе", "Неверный формат e-mail", "emailAddress"),
    ("Профиль", "Телефон", "необязательно; 9 цифр, начинается с 0",
     "9 цифр, начиная с 0 (например, 069123456)", "phone, digitsOnly, ≤ 9"),
]

PROBLEMS = [
    ("После перехода на GoRouter 6 тестов упали, хотя по одному проходили.",
     "router — глобальный объект и помнит адрес между тестами. Добавлен setUp(() => router.go('/login'))."),
    ("Риск: адреса /diary/new и /diary/unlock попали бы в переменный сегмент :id и int.parse упал бы.",
     "Фиксированные дочерние маршруты стоят выше ':id' — маршруты пробуются сверху вниз."),
    ("Экран пароля Скинии оставался бы в стеке, если бы Скиния была его дочерним маршрутом.",
     "Скиния — соседний маршрут /diary/tabernacle, переход — go: «назад» ведёт в Дневник."),
    ("В тесте формы кнопка «Сохранить» оказывалась под панелью вкладок (экран 800×600).",
     "Тестовый экран увеличен до 800×1600."),
    ("adb shell input text не вводит кириллицу — нельзя заполнить форму по-русски для скриншота.",
     "Заголовок и текст введены транслитом; ссылку «Ин 3» подставил сам переход из главы (?verse=)."),
]

EXTRA_CSS = """
figure { margin: 0; text-align: center; }
figcaption { font-size: 9pt; color: #444; margin-top: 2pt; max-width: 41mm; }
td code { font-size: 9pt; }
.small-table { font-size: 10pt; }
"""


def table(header, rows) -> str:
    th = "".join(f"<th>{h}</th>" for h in header)
    trs = "".join(
        "<tr>" + "".join(f"<td>{html.escape(c)}</td>" for c in r) + "</tr>" for r in rows
    )
    return f'<table class="small-table"><tr>{th}</tr>{trs}</table>'


def build_html() -> str:
    t = dict(base.TITLE)
    t["work"] = "Лабораторная работа № 3"
    t["work_title"] = "Многоэкранная навигация, формы и валидация"
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
<p><b>{html.escape(t['theme'])}.</b> ЛР3 продолжает проект ЛР2 (тот же репозиторий): первый
коммит — <code>flutter pub add go_router</code> (в <code>pubspec.yaml</code> появилась зависимость
<code>go_router: ^18.1.0</code>, точная версия зафиксирована в <code>pubspec.lock</code>).</p>
<p>Приложение навигирует по адресам (<code>lib/router.dart</code>, <code>MaterialApp.router</code>),
главные разделы — постоянные вкладки на <code>StatefulShellRoute.indexedStack</code>, у моделей
появился <code>id</code> (книга 1–66, запись дневника, группа), детали получают id из адреса и сами
ищут объект. Формы проверяют данные (<code>Form</code> + <code>TextFormField</code> + <code>validator</code>),
вход — с локальной валидацией и <code>context.go</code>, деструктивные действия — с диалогом
подтверждения. Данные остаются mock: после «Сохранить» список не растёт — это контракт ЛР3,
состояние появится в ЛР4, реальная аутентификация — в ЛР5.</p>

<h1>2. Карта маршрутов</h1>
<p>Правило: <b>push</b> — «зашёл и вернулся» (детали, формы, поиск); <b>go</b> — прыжок между
разделами и случаи, когда предыдущий экран должен уйти из стека (после входа, выход, после
пароля Скинии, «В дневник» из главы). Параметр пути — всегда <code>String</code>, его переводит
в число <code>int.parse</code>; знак <code>!</code> оправдан, так как маршрут гарантирует наличие
параметра. Объекты через <code>extra</code> не передаются — только id в адресе.</p>
{table(["Адрес", "Экран", "Как открывается", "Почему"], ROUTES)}
<h2>lib/router.dart</h2>
{base.code("lib/router.dart")}
<h2>lib/widgets/app_shell.dart</h2>
<p>Обёртка вкладок — <code>StatelessWidget</code>: текущий индекс знает router
(<code>navigationShell.currentIndex</code>), переключение — <code>navigationShell.goBranch</code>.
StatefulWidget-«леса» ЛР2 (<code>MainShell</code> с <code>setState</code> на индексе) удалены.</p>
{base.code("lib/widgets/app_shell.dart")}

<h1>3. Цепочки «список → детали» и вкладки</h1>
<p>Карточка списка получает <code>onTap: () =&gt; context.push('/diary/${{entry.id}}')</code>,
экран деталей ищет объект сам: <code>MockData.books.firstWhere((b) =&gt; b.id == bookId)</code>.
Сегодня — в mock-данных, в ЛР4 — через Repository, в ЛР5 — с сервера; адрес не меняется.</p>
<h2>Библия: книга → глава (разные id)</h2>
{shots(("30_chain_book_1.png", "/bible/1 — Бытие"), ("31_chain_chapter_1_1.png", "/bible/1/1 — текст с сервера в ЛР5"), ("32_chain_chapter_43_3.png", "/bible/43/3 — От Иоанна 3"))}
<h2>Дневник и Вместе: записи и группы (разные id)</h2>
{shots(("33_chain_entry_1.png", "/diary/1"), ("34_chain_entry_2.png", "/diary/2"), ("36_chain_group_1.png", "/together/1"), ("37_chain_group_2.png", "/together/2"))}
<h2>Shell на каждом пункте назначения</h2>
{shots(("20_tab_day.png", "/day"), ("21_tab_bible.png", "/bible"), ("22_tab_diary.png", "/diary"))}
{shots(("23_tab_together.png", "/together"), ("24_tab_profile.png", "/profile"))}
<h2>Проверка по четырём пунктам</h2>
<p>(a) Вкладка помнит прокрутку: «Библия» прокручена до «Иова», переход в «Дневник» и обратно —
список на том же месте. (b) Детали открываются внутри вкладки, панель видна, «назад» работает.
(c) У экрана входа панели нет. (d) После входа <code>go('/day')</code> приводит на первую вкладку.</p>
{shots(("01_shell_bible_scroll_kept.png", "(a) прокрутка сохранена"), ("02_shell_book_inside_tab.png", "(b) детали внутри вкладки"), ("03_shell_after_login_day.png", "(d) после входа — /day"))}

<h1>4. Формы</h1>
<p>Все формы — <code>StatefulWidget</code>: <code>GlobalKey&lt;FormState&gt;</code>, контроллеры
живут в <code>State</code> и освобождаются в <code>dispose()</code> (по одному вызову на
контроллер). Submit: <code>validate()</code> → при ошибке <code>return</code> (ошибки уже на
экране, их рисует сам <code>TextFormField</code>), иначе SnackBar + <code>pop()</code>/<code>go()</code>.
Правила — в <code>lib/utils/validators.dart</code>: validator возвращает текст ошибки или
<code>null</code>, что означает «верно».</p>
<p><b>Валидация темы.</b> Ссылка на стих проверяется по данным Библии: книга должна существовать
(по сокращению), а номер главы — не превышать число глав в книге.</p>
{table(["Форма", "Поле", "Правило", "Сообщение", "Клавиатура / фильтр"], RULES)}
<h2>Новая запись: подстановка из главы → ошибки → сохранение</h2>
{shots(("40_form_entry_prefilled.png", "«В дневник» из Ин 3: ?verse=Ин 3"), ("41_form_entry_errors.png", "«Ин 30» и пустые поля"), ("42_form_entry_saved_snackbar.png", "сохранено → SnackBar, pop()"))}
<h2>Пароль Скинии и профиль</h2>
{shots(("43_form_pin_error.png", "«12ab»: буквы отфильтрованы"), ("35_tabernacle_after_pin.png", "«1234» → go в Скинию"), ("44_form_profile_errors.png", "e-mail и телефон"))}
<h2>lib/utils/validators.dart</h2>
{base.code("lib/utils/validators.dart")}

<h1>5. Аутентификация</h1>
<p>Экран входа стал <code>StatefulWidget</code> с <code>Form</code>: e-mail (не пусто, формат
<code>x@y.z</code>, клавиатура <code>emailAddress</code>) и пароль (не короче 6 символов,
<code>obscureText</code>). Любые данные, прошедшие проверку, впускают — сверка с пользователем
появится в ЛР5.</p>
<p><b>Почему go.</b> После успешной проверки вызывается <code>context.go('/day')</code>, а не
<code>push</code>: стек становится стеком адреса <code>/day</code>, экран входа из него уходит,
и системная «назад» не может вернуть вошедшего пользователя на вход. На эмуляторе «назад» на
«Моём дне» закрывает приложение; в тестах проверено <code>router.canPop() == false</code> после входа.</p>
{shots(("11_login_empty_errors.png", "пустая форма"), ("12_login_invalid_errors.png", "неверный формат"), ("13_after_logout_login.png", "после выхода — вход без вкладок"))}

<h1>6. Обратная связь</h1>
<p>Только сообщаем — <b>SnackBar</b> («Запись … сохранена», «Запись … удалена», «Профиль сохранён»,
«Помолюсь», «Закладка»). Просим решение — <b>диалог с await</b>: «Удалить запись?»,
«Покинуть группу?», «Выйти из аккаунта?». Диалог закрывается через <code>dialogCtx</code>
(под вложенными навигаторами вкладок <code>pop(context)</code> закрыл бы экран, а не диалог),
результат — <code>ok == true</code> (закрытие мимо даёт <code>null</code>), после
<code>await</code> контекст используется только при <code>context.mounted</code>.</p>
{shots(("50_dialog_delete_entry.png", "Удалить запись?"), ("51_snackbar_entry_deleted.png", "SnackBar после удаления"), ("52_dialog_leave_group.png", "Покинуть группу?"), ("53_dialog_logout.png", "Выйти из аккаунта?"))}
<h2>lib/widgets/confirm_dialog.dart</h2>
{base.code("lib/widgets/confirm_dialog.dart")}

<h1>7. Проблемы и их решение</h1>
{table(["Проблема", "Решение"], PROBLEMS)}
<p>Каждый шаг проверялся командой <code>flutter analyze</code> (без замечаний) и виджет-тестами
<code>flutter test</code> — 16 тестов: детали по id из адреса, ошибки входа, правила валидации,
форма записи (ошибки → SnackBar), диалог выхода и отсутствие дороги назад после входа.</p>

<h1>8. История Git</h1>
<p>Вывод <code>git log --oneline</code> полностью — от начала проекта (ЛР2) до сегодня:</p>
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
