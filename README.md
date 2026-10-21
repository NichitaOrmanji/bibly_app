# Bibly

Мобильное приложение для ежедневного чтения Библии, дневника и совместного
чтения с друзьями. Учебный проект по дисциплине «Программирование мобильных
приложений» (PAM), Flutter + Material 3.

## Состояние: ЛР2 — статический UI

Все экраны построены как статический макет с данными, зашитыми в код
(`lib/data/mock_data.dart`). Навигация — минимальная (`NavigationBar` +
`Navigator.push`), без валидации, состояния и бэкенда — они появятся в ЛР3–ЛР5.

| Экран | Файл |
|-------|------|
| Вход | `lib/screens/login_screen.dart` |
| Мой день | `lib/screens/my_day_screen.dart` |
| Библия — список книг | `lib/screens/bible_screen.dart` |
| Чтение главы | `lib/screens/chapter_screen.dart` |
| Поиск | `lib/screens/search_screen.dart` |
| Дневник | `lib/screens/diary_screen.dart` |
| Скиния — вход по паролю | `lib/screens/tabernacle_lock_screen.dart` |
| Скиния — личные записи | `lib/screens/tabernacle_screen.dart` |
| Вместе | `lib/screens/together_screen.dart` |
| Профиль / настройки | `lib/screens/profile_screen.dart` |

## Структура

```
lib/
├── main.dart     — MaterialApp, светлая и тёмная тема, стартовый экран
├── screens/      — по одному файлу на экран + оболочка с NavigationBar
├── widgets/      — переиспользуемые виджеты
├── models/       — классы данных (книга, стих, запись, группа…)
├── data/         — mock_data.dart: статические данные
└── utils/        — тема (seed-цвет) и константы отступов
```

## Запуск

```bash
flutter pub get
flutter run
```

Тесты: `flutter test`.

## Backend (ЛР5)

Сервер лежит в `server/`. Это backend-шаблон курса PAM, **порт на Dart** (Dart + Shelf + SQLite).
Dart выбран потому, что он уже установлен вместе с Flutter и приложение и сервер
написаны на одном языке.

```bash
cd server
dart pub get
dart run          # слушает http://localhost:8080, app.db создаётся сам
```

Переменные окружения: `PORT` (по умолчанию 8080), `JWT_SECRET`.
На Windows пакету `sqlite3` нужен `sqlite3.dll` рядом с сервером. Подойдёт копия
из `Python\DLLs\` или dll с sqlite.org. Файл в `.gitignore`.
Из эмулятора Android сервер доступен по адресу `http://10.0.2.2:8080`.
