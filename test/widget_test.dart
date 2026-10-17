import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bibly_app/main.dart';

void main() {
  testWidgets('Login screen is static and leads to home', (tester) async {
    await tester.pumpWidget(const BiblyApp());

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Войти'), findsOneWidget);

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Добро пожаловать в Bibly'), findsOneWidget);
  });

  testWidgets('Login screen fits a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BiblyApp());
    expect(tester.takeException(), isNull);
  });
}
