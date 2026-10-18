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

### Задание 3. Паттерн Repository
- `lib/data/result.dart` — `sealed class Result<T>` с `Ok(value)` и `Err(msg)`: ожидаемый отказ —
  значение, а не исключение; `switch` по sealed-типу исчерпывающий.
- Интерфейсы (контракт «что можно просить»), у каждого метода — будущий REST-эндпоинт в комментарии:
  - `DiaryRepository` — CRUD главной сущности: `fetchAll`, `fetchById`, `create`, `update`, `delete`;
  - `BibleRepository` — `fetchBooks`, `fetchChapter(bookId, chapter)`, `search(query)`;
  - `CommunityRepository` — `fetchGroups`, `fetchFeed`, `leaveGroup(id)`;
  - `ProfileRepository` — `fetch`, `update` (вторая пишущая сущность);
  - `DailyRepository` — `fetchToday`, `setTaskDone(id, done)`.
- Классы сущностей уже жили отдельно в `lib/models/` (с ЛР2), их не надо выносить из
  `mock_data.dart`. Новые сущности: `UserProfile`, `DayPlan`, `ChapterText`.
  `DiaryEntry.copyWith` — «та же запись, другая идентичность» для `create`.
- Реализации в `lib/data/mock/`:
  - `MockNetwork` — общая «сеть»: `Future.delayed(800 мс)` и флаг аварии `simulateError`
    (один переключатель роняет все хранилища, как настоящая потеря сети);
  - `MockDiaryRepository` — память + пролог `roundTrip()`; `create` даёт id с 1000;
    `fetchById/update/delete` с несуществующим id → `Err('Запись не существует')` («404»);
  - `MockBibleRepository` (поиск по основе слова: «любовь» находит «любит», «любви»),
    `MockCommunityRepository`, `MockProfileRepository`, `MockDailyRepository`.
- `mock_data.dart` теперь только seed: в него добавлен `MockData.user` (профиль).
- `test/repository_test.dart`: id от хранилища, «404» на delete/fetchById, авария → `Err`, поиск.

### Задание 4. Модели с хранилищем и три состояния
- Модели (`lib/models/*_model.dart`) получают хранилище **через конструктор**, тип поля —
  **интерфейс**; у каждой триада `isLoading` / `error` / данные и `load()` по шаблону C8
  (`notifyListeners` на входе в «грузится» и на выходе — с данными или ошибкой):
  `DayPlanModel(DailyRepository)` (теперь грузит план и пишет отметки через хранилище),
  `DiaryModel(DiaryRepository)` (+ `byId`, `publicEntries`, `privateEntries`, `add/update/remove`),
  `BibleModel(BibleRepository)` (книги, кэш глав по ключу «книга:глава» со своей триадой, поиск),
  `CommunityModel(CommunityRepository)` (группы + лента параллельно через `(a, b).wait`, `leaveGroup`),
  `ProfileModel(ProfileRepository)` (+ `update`).
- Мутации возвращают `Future<String?>`: `null` — успех, иначе сообщение (как у validator).
- **Корень композиции** `main.dart`: `createApp()` создаёт `MockNetwork` и пять mock-хранилищ
  в переменные с типом интерфейса; `MultiProvider`: `Provider<MockNetwork>.value` (леса аварии)
  и пять `ChangeNotifierProvider(create: (_) => XModel(repo)..load())` — фабрика + первая загрузка.
- `lib/widgets/error_view.dart` — `ErrorView`: иконка, сообщение и `FilledButton` «Повторить» (`onRetry`).
- **Мой день** мигрирован: `watch<DayPlanModel>()` + `watch<ProfileModel>()` в build →
  спиннер / `ErrorView` (retry грузит обе модели) / данные; имя, серия дней и «Продолжить» —
  из профиля, стих и дата — из плана. Галочка — `read<DayPlanModel>().toggle(id)`; при ошибке SnackBar.
- Экраны мигрированы на модели, по коммиту на экран (у каждого — три состояния):
  - **Библия, Книга** — `BibleModel`; «Продолжить» — из `ProfileModel` (книга по `byId`);
    книга по id: `null` → спиннер, пока список грузится, иначе «Книга не существует»;
  - **Чтение главы** — `StatefulWidget`, в `initState` после первого кадра
    `read<BibleModel>().loadChapter(...)`; кэш глав со своей триадой; несуществующая глава → `Err` → `ErrorView`;
  - **Поиск** — стал настоящим: `TextField` → `BibleModel.search`; недавние запросы приходят
    из хранилища и пополняются удачными запросами; фильтры работают (завет книги по сокращению;
    «Мой дневник» — поиск по `DiaryModel` со своей триадой). Выбранный фильтр — `setState`.
    Тест поймал ошибку: без триады у фильтра «Мой дневник» загрузка шла «молча» — исправлено;
  - **Дневник, Скиния, Запись** — `DiaryModel` (`publicEntries` / `privateEntries` / `byId`);
  - **Вместе, Группа** — `CommunityModel`; участники приходят из хранилища вместе с группой
    (`ReadingGroup.memberNames`);
  - **Профиль** — `ProfileModel` (имя, e-mail, статистика, значения настроек), число
    записей — из `DiaryModel`; версия приложения — `AppConstants.appVersion`.

### Задание 5. Мутации: одна весть — все экраны
- Удаление записи: диалог из ЛР3 получил эффект — `ok == true && mounted` →
  `read<DiaryModel>().remove(id)` → снова `mounted` (экран мог умереть, пока «запрос» летел) →
  ошибка → SnackBar с сообщением; успех → SnackBar + `context.pop()`.
- Свайп по карточке в Дневнике и Скинии — `Dismissible(key: ValueKey(entry.id))`
  (идентичность из данных, не `UniqueKey`), `confirmDismiss` показывает тот же диалог и удаляет
  через модель; строка уходит только если хранилище ответило `Ok`.
- «Покинуть группу» — `CommunityModel.leaveGroup(id)`: группа исчезает из «Мои группы».
- Отметка пункта плана — `DayPlanModel.toggle` пишет через `DailyRepository.setTaskDone`.
- Мультиэкранная проверка (тест): было 13 записей в профиле → удалили «Господь — Пастырь мой»
  в деталях → детали закрылись, записи нет в списке Дневника, в профиле «12». Никто ничего не
  перезагружал — всех известил `notifyListeners`.
- В тестах появился `waitNetwork()`: задержка mock-а идёт без анимации, и одного
  `pumpAndSettle` мало. 22 теста пройдены.
