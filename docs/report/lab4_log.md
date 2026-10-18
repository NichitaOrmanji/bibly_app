# Журнал выполнения ЛР4 — State management и Repository (Bibly)

Материал для отчёта. Скриншоты — в `screenshots_l4/`. Проект продолжает ЛР3.

## Что разделяемое, а что эфемерное (решение по таксономии C7)

| Состояние | Куда | Почему |
|---|---|---|
| Отметки плана дня | `DayPlanModel` (ChangeNotifier) | видят «Мой день» и бейдж на вкладке; переживает навигацию |
| Записи дневника (главная сущность, CRUD) | `DiaryModel` + `DiaryRepository` | Дневник, Скиния, детали, статистика профиля |
| Книги, главы, поиск | `BibleModel` + `BibleRepository` | Библия, книга, глава, поиск, валидатор формы |
| Группы и лента | `CommunityModel` + `CommunityRepository` | Вместе, группа |
| Профиль пользователя | `ProfileModel` + `ProfileRepository` | Профиль, приветствие в «Моём дне», форма профиля |
| «Показать пароль», выбор в Dropdown, текст в полях, переключатель аварии | `setState` в State | нужно одному экрану, не переживает уход с него |

## Ход работы

### Задание 1. Пакет provider
- `flutter pub add provider` → `provider: ^6.1.5+1` в `pubspec.yaml`. Коммит «L4: добавлен пакет provider».

### Задание 2. Разделяемое состояние: модель плана дня
- `DailyTask` получил `id` и `copyWith({bool? isDone})` — объекты неизменяемы, «отметить» = создать копию.
- `lib/models/day_plan_model.dart` — `DayPlanModel extends ChangeNotifier`, чистый Dart
  (импорт только `package:flutter/foundation.dart`):
  внутренний список приватный, наружу `List.unmodifiable`; `toggle(id)` заканчивается
  `notifyListeners()`; производные `doneCount`, `remaining`.
- Монтирование в `main.dart` — `ChangeNotifierProvider(create: ...)` с **фабрикой**
  (Provider создаёт лениво и сам вызывает dispose). Появилась функция `createApp()` —
  тесты получают свежее состояние на каждый тест.
- Три формы потребления:
  - **watch в build** — «Мой день»: прогресс «2 из 4» и полоска;
  - **read в callback-е** — кнопка-галочка `DailyTaskTile.onToggle` → `context.read<DayPlanModel>().toggle(id)`;
  - **Consumer** — бейдж «осталось N» на вкладке «Мой день» в `AppShell`
    (виджет `_PlanBadge`, обёрнуты и обычная, и выбранная иконка — иначе на выбранной
    вкладке бейдж пропадал).
- Тест: отметка пункта меняет «2 из 4» → «3 из 4» и бейдж 2 → 1 в другом виджете. 17 тестов пройдены.
