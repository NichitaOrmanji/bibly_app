# Журнал выполнения ЛР3 — навигация, формы и валидация (Bibly)

Материал для отчёта. Скриншоты — в `screenshots_l3/`.
Проект продолжает ЛР2 (тот же репозиторий, та же история Git).

## План маршрутов

```
/login                         вне shell, без вкладок
/search                        вне shell, открывается push-ем
StatefulShellRoute.indexedStack (AppShell + NavigationBar)
├─ /day                        Мой день
├─ /bible                      список книг
│   └─ :bookId                 главы книги          (push)
│       └─ :chapter            чтение главы         (push; соседние главы — go)
├─ /diary                      Дневник
│   ├─ new                     форма новой записи (перед :id!)
│   ├─ tabernacle              пароль Скинии → go в entries
│   │   └─ entries             Скиния
│   └─ :id                     детали записи
├─ /together                   Вместе
│   └─ :groupId                детали группы
└─ /profile                    Профиль
    └─ edit                    форма профиля
```

## Ход работы

### Шаг 1. Пакет go_router
- `flutter pub add go_router` → в `pubspec.yaml` появилась зависимость `go_router: ^18.1.0`,
  точная версия зафиксирована в `pubspec.lock`.
- Коммит: «L3: добавлен пакет go_router».

### Шаг 2. Модели получают id
- `BibleBook.id` — номер книги в синодальном порядке (1 — Бытие … 43 — От Иоанна … 66 — Откровение).
- `DiaryEntry.id` — записи Дневника 1–7, записи Скинии 101–106 (не пересекаются).
- `ReadingGroup.id` — группы 1–6.
- `MockData.lastReadBookId = 43` — для адреса «Продолжить чтение» `/bible/43/3`.

### Шаг 3. Карта маршрутов: router.dart и MaterialApp.router
- `lib/router.dart`: глобальный `GoRouter` с `initialLocation: '/login'`, у каждого экрана свой адрес.
  Пока карта плоская; вкладки остаются в `MainShell` до шага со `StatefulShellRoute`.
- `main.dart`: `MaterialApp` → `MaterialApp.router(routerConfig: router)`, параметр `home:` удалён.
- Все «леса» ЛР2 (`Navigator.push` + `MaterialPageRoute`) заменены адресами:
  - лупа → `context.push('/search')`;
  - «Продолжить» и пункт «Отрывок из Библии» → `context.push('/bible/43/3')`;
  - Скиния → `context.push('/diary/unlock')`, после пароля `context.go('/diary/tabernacle')`;
  - «Войти» → `context.go('/day')`, «Выйти» → `context.go('/login')`.
- `ChapterScreen` теперь получает `bookId` и `chapter` из адреса `/bible/:bookId/:chapter`
  (`int.parse(state.pathParameters[...]!)` — параметр пути всегда `String`) и сам ищет книгу
  через `firstWhere`. Текст есть только у Ин 3, для других глав — заглушка «загрузится с сервера (ЛР5)».
  Соседние главы — `context.pushReplacement`, чтобы «назад» вела к списку, а не по всем главам.
- Проблема: после перехода на `GoRouter` 6 тестов упали, хотя по одному проходили. Причина —
  `router` глобальный и помнит адрес между тестами. Решение: `setUp(() => router.go('/login'))`.
- Проверка: `flutter analyze` — без замечаний; 10 тестов пройдены.
