import 'package:flutter_test/flutter_test.dart';

import 'package:bibly_app/main.dart';

void main() {
  testWidgets('App starts', (tester) async {
    await tester.pumpWidget(const BiblyApp());
    expect(find.text('Bibly'), findsOneWidget);
  });
}
