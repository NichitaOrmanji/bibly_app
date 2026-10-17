import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bibly_app/main.dart';

void main() {
  testWidgets('Theme toggle switches between light and dark', (tester) async {
    await tester.pumpWidget(const BiblyApp());

    final toggle = find.byType(IconButton);
    expect(toggle, findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    final first = Theme.of(tester.element(toggle)).brightness;

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    final second = Theme.of(tester.element(toggle)).brightness;

    expect(first, isNot(second));
  });
}
