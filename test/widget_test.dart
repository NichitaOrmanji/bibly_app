import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/mock_data.dart';
import 'fakes/mock_network.dart';
import 'fakes/test_app.dart';

import 'package:bibly_app/router.dart';
import 'package:bibly_app/screens/new_entry_screen.dart';
import 'package:bibly_app/utils/validators.dart';
import 'package:bibly_app/widgets/book_tile.dart';
import 'package:bibly_app/widgets/initials_avatar.dart';
import 'package:bibly_app/widgets/stat_tile.dart';

/// Даёт mock-хранилищу «ответить»: задержка 800 мс идёт без анимации,
/// поэтому одного pumpAndSettle мало.
Future<void> waitNetwork(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

/// Вводит корректные данные и нажимает «Войти».
Future<void> logIn(WidgetTester tester) async {
  await tester.enterText(
    find.byType(TextFormField).at(0),
    'nikita@example.com',
  );
  await tester.enterText(find.byType(TextFormField).at(1), 'secret12');
  await tester.tap(find.text('Войти'));
  await tester.pumpAndSettle();
}

void main() {
  // router — глобальный объект и помнит адрес между тестами:
  // каждый тест начинаем с экрана входа.
  // С ЛР5 router строит main(); в тестах — один раз, со стартом на входе.
  setUpAll(() => router = buildRouter(initialLocation: '/login'));
  setUp(() => router.go('/login'));

  testWidgets('Login screen is static and leads to My day', (tester) async {
    await tester.pumpWidget(testApp());

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Войти'), findsOneWidget);

    await logIn(tester);
    expect(find.text('Стих дня'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Login screen fits a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(testApp());
    expect(tester.takeException(), isNull);
  });

  testWidgets('My day fits a small phone and tabs switch', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(testApp());
    await logIn(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Вместе'));
    await tester.pumpAndSettle();
    expect(find.text('Мои группы'), findsOneWidget);
    expect(find.text('Лента друзей'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bible tab lists books of both testaments', (tester) async {
    await tester.pumpWidget(testApp());
    await logIn(tester);

    await tester.tap(find.text('Библия'));
    await tester.pumpAndSettle();
    expect(find.text('Ветхий Завет'), findsOneWidget);
    expect(find.text('Бытие'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Chapter count is declined in Russian', () {
    expect(BookTile.chaptersLabel(1), '1 глава');
    expect(BookTile.chaptersLabel(3), '3 главы');
    expect(BookTile.chaptersLabel(12), '12 глав');
    expect(BookTile.chaptersLabel(21), '21 глава');
    expect(BookTile.chaptersLabel(150), '150 глав');
  });

  testWidgets('Diary opens Tabernacle via password screen', (tester) async {
    await tester.pumpWidget(testApp());
    await logIn(tester);

    await tester.tap(find.text('Дневник'));
    await tester.pumpAndSettle();
    expect(find.text('Мои записи'), findsOneWidget);

    await tester.tap(find.text('Скиния'));
    await tester.pumpAndSettle();
    expect(find.text('Пароль Скинии'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '1234');
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    expect(find.text('Эти записи видны только вам'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Continue reading opens the chapter', (tester) async {
    await tester.pumpWidget(testApp());
    await logIn(tester);

    await tester.tap(find.text('Библия'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Беседа Иисуса с Никодимом'), findsOneWidget);
    expect(find.text('В дневник'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile shows stats and settings, logout returns to login', (
    tester,
  ) async {
    await tester.pumpWidget(testApp());
    await logIn(tester);

    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Никита Орманжи'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Перевод Библии'), 200);
    expect(find.text('Перевод Библии'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(find.text('Выйти'), 200);
    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Да, выйти'));
    await tester.pumpAndSettle();
    expect(find.text('Войти'), findsOneWidget);
  });

  test('Initials are taken from the first two words', () {
    expect(InitialsAvatar.initialsOf('Никита Орманжи'), 'НО');
    expect(InitialsAvatar.initialsOf('Андрей'), 'А');
  });

  testWidgets('Search opens from My day and shows results', (tester) async {
    await tester.pumpWidget(testApp());
    await logIn(tester);

    await tester.tap(find.byTooltip('Поиск'));
    await tester.pumpAndSettle();
    expect(find.text('Введите слово или ссылку на стих'), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(4));

    await tester.enterText(find.byType(TextField), 'любовь');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Найдено стихов: 7'), findsOneWidget);

    await tester.tap(find.text('Мой дневник'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Найдено записей:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Detail screens find their object by id from the address', (
    tester,
  ) async {
    await tester.pumpWidget(testApp());

    router.go('/bible/1');
    await tester.pumpAndSettle();
    expect(find.text('Бытие'), findsOneWidget);
    expect(find.text('50'), findsOneWidget); // последняя глава в сетке

    router.go('/bible/43/3');
    await tester.pumpAndSettle();
    expect(find.text('Беседа Иисуса с Никодимом'), findsOneWidget);

    router.go('/diary/2');
    await tester.pumpAndSettle();
    expect(find.text('Господь — Пастырь мой'), findsOneWidget);

    router.go('/diary/tabernacle/101');
    await tester.pumpAndSettle();
    expect(find.text('Молитва о маме'), findsOneWidget);

    router.go('/together/2');
    await tester.pumpAndSettle();
    expect(find.text('Студенты УТМ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login rejects invalid data and stays on the login screen', (
    tester,
  ) async {
    await tester.pumpWidget(testApp());

    await tester.tap(find.text('Войти'));
    await tester.pump();
    expect(find.text('Введите e-mail'), findsOneWidget);
    expect(find.text('Введите пароль'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'nikita.example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.text('Войти'));
    await tester.pump();
    expect(find.text('Неверный формат e-mail'), findsOneWidget);
    expect(find.text('Минимум 6 символов'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing); // всё ещё на входе
  });

  test('Verse reference is checked against real books and chapters', () {
    expect(
      Validators.verseReference('', MockData.books),
      isNull,
    ); // необязательное поле
    expect(Validators.verseReference('Ин 3:16', MockData.books), isNull);
    expect(Validators.verseReference('1 Кор 13', MockData.books), isNull);
    expect(
      Validators.verseReference('Ин', MockData.books),
      'Формат: «Ин 3:16» или «1 Кор 13»',
    );
    expect(
      Validators.verseReference('Абв 1', MockData.books),
      'Нет такой книги: «Абв»',
    );
    expect(
      Validators.verseReference('Ин 22', MockData.books),
      'В книге «От Иоанна» глав: 21',
    );
  });

  test('Tabernacle PIN and phone rules', () {
    expect(Validators.tabernaclePin(''), 'Введите пароль Скинии');
    expect(Validators.tabernaclePin('12'), 'От 4 до 6 цифр');
    expect(Validators.tabernaclePin('1234'), isNull);
    expect(Validators.phone(''), isNull);
    expect(Validators.phone('69123456'), isNotNull);
    expect(Validators.phone('069123456'), isNull);
  });

  testWidgets('New entry form shows errors, then saves with a SnackBar', (
    tester,
  ) async {
    // Высокий экран: вся форма помещается над панелью вкладок.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(testApp());
    await logIn(tester);
    router.go('/diary');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Новая запись'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Сохранить'));
    await tester.pump();
    expect(find.text('Заголовок обязателен'), findsOneWidget);
    expect(find.text('Напишите хотя бы пару слов'), findsOneWidget);
    expect(find.text('Выберите, куда сохранить запись'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Утро с Псалмом');
    await tester.enterText(fields.at(1), 'Пс 22');
    await tester.enterText(fields.at(2), 'Перечитал Псалом 22 перед парами.');
    await tester.tap(find.byType(DropdownButtonFormField<EntryPlace>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дневник — видна группе').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await waitNetwork(tester); // create идёт через «сеть» mock-а
    expect(
      find.text('Запись «Утро с Псалмом» сохранена в Дневник'),
      findsOneWidget,
    );
    expect(find.text('Мои записи'), findsOneWidget); // форма закрылась
    // Список позади уже вырос: новая запись — сверху, счётчик 7 → 8.
    expect(find.text('Утро с Псалмом'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('Logout asks for confirmation; back does not return to login', (
    tester,
  ) async {
    await tester.pumpWidget(testApp());
    await logIn(tester);

    // После входа стек — это /day: возвращаться на вход некуда.
    expect(router.canPop(), isFalse);

    router.go('/profile');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Выйти'), 200);
    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();
    expect(find.text('Выйти из аккаунта?'), findsOneWidget);

    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(find.text('Выйти из аккаунта?'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget); // остались в профиле

    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Да, выйти'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing); // экран входа
    expect(find.text('Войти'), findsOneWidget);
  });

  testWidgets('Toggling a task updates progress and the tab badge', (
    tester,
  ) async {
    // Высокий экран: весь план помещается без прокрутки.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(testApp());
    await logIn(tester);

    expect(find.text('2 из 4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // бейдж «осталось 2»

    await tester.tap(find.byTooltip('Отметить выполненным').first);
    await tester.pumpAndSettle();
    expect(find.text('3 из 4'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // бейдж на вкладке уменьшился
  });

  testWidgets('Deleting an entry removes it from the list and the profile', (
    tester,
  ) async {
    await tester.pumpWidget(testApp());
    await logIn(tester);

    router.go('/profile');
    await tester.pumpAndSettle();
    await waitNetwork(tester); // DiaryModel создаётся лениво — ждём ответа
    expect(find.text('13'), findsOneWidget); // 7 записей + 6 в Скинии

    router.go('/diary/2');
    await tester.pumpAndSettle();
    expect(find.text('Господь — Пастырь мой'), findsOneWidget);
    await tester.tap(find.byTooltip('Удалить'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Удалить'));
    await waitNetwork(tester); // удаление идёт через «сеть» mock-а

    // Детали закрылись, запись исчезла из списка Дневника…
    expect(find.text('Мои записи'), findsOneWidget);
    expect(find.text('Господь — Пастырь мой'), findsNothing);
    // …и из статистики профиля — никто ничего не перезагружал.
    router.go('/profile');
    await tester.pumpAndSettle();
    final entriesTile = find.widgetWithText(StatTile, 'записей');
    expect(
      find.descendant(of: entriesTile, matching: find.text('12')),
      findsOneWidget,
    );
  });

  testWidgets('Profile form writes through the model; greeting updates', (
    tester,
  ) async {
    await tester.pumpWidget(testApp());
    await logIn(tester);
    expect(find.text('Доброе утро, Никита!'), findsOneWidget);

    router.go('/profile/edit');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Мария Лупу');
    await tester.tap(find.text('Сохранить'));
    await waitNetwork(tester);
    expect(find.text('Профиль сохранён'), findsOneWidget);
    expect(find.text('Мария Лупу'), findsOneWidget); // экран профиля

    router.go('/day');
    await tester.pumpAndSettle();
    expect(find.text('Доброе утро, Мария!'), findsOneWidget);
  });

  testWidgets('Network failure: error view, retry brings data back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final net = MockNetwork(); // с ЛР5 переключателя в профиле нет —
    await tester.pumpWidget(testApp(net: net)); // аварию включает тест
    await logIn(tester);
    net.simulateError = true;

    // Дневник ещё не загружался: первая загрузка падает → экран ошибки.
    router.go('/diary');
    await tester.pumpAndSettle();
    await waitNetwork(tester);
    expect(find.text('Сервер не отвечает — повторите попытку'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);

    // Авария выключена → «Повторить» → данные вернулись.
    net.simulateError = false;
    await tester.tap(find.text('Повторить'));
    await waitNetwork(tester);
    expect(find.text('Мои записи'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Crash switch is gone from the profile', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(testApp());
    await logIn(tester);
    router.go('/profile');
    await waitNetwork(tester);
    await waitNetwork(tester); // профиль и счётчик записей грузятся по очереди
    expect(find.text('Симулировать сбой сети'), findsNothing);
    expect(find.text('Выйти'), findsOneWidget);
  });
}
