import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bibly_app/main.dart';
import 'package:bibly_app/widgets/book_tile.dart';

void main() {
  testWidgets('Login screen is static and leads to My day', (tester) async {
    await tester.pumpWidget(const BiblyApp());

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Войти'), findsOneWidget);

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Стих дня'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Login screen fits a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BiblyApp());
    expect(tester.takeException(), isNull);
  });

  testWidgets('My day fits a small phone and tabs switch', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BiblyApp());
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Вместе'));
    await tester.pumpAndSettle();
    expect(find.text('Раздел «Вместе» скоро появится'), findsOneWidget);
  });

  testWidgets('Bible tab lists books of both testaments', (tester) async {
    await tester.pumpWidget(const BiblyApp());
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(const BiblyApp());
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Дневник'));
    await tester.pumpAndSettle();
    expect(find.text('Мои записи'), findsOneWidget);

    await tester.tap(find.text('Скиния'));
    await tester.pumpAndSettle();
    expect(find.text('Пароль Скинии'), findsOneWidget);

    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    expect(find.text('Эти записи видны только вам'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Continue reading opens the chapter', (tester) async {
    await tester.pumpWidget(const BiblyApp());
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Библия'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Беседа Иисуса с Никодимом'), findsOneWidget);
    expect(find.text('В дневник'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
