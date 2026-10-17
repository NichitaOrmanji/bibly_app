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
