import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bibly_app/data/api_message.dart';
import 'package:bibly_app/data/auth_api.dart';
import 'package:bibly_app/data/result.dart';
import 'package:bibly_app/data/token_store.dart';
import 'package:bibly_app/router.dart';

import 'fakes/test_app.dart';

/// Сервер отвечает ошибкой: вход не удаётся с переведённым сообщением.
class RejectingAuthApi extends AuthApi {
  RejectingAuthApi() : super('', TokenStore());

  String? lastName;

  @override
  Future<Result<void>> login(String email, String password) async =>
      const Err('Неверный email или пароль');

  @override
  Future<Result<void>> register(
    String email,
    String password,
    String name,
  ) async {
    lastName = name;
    return const Err('Аккаунт с этим email уже существует');
  }
}

void main() {
  group('apiMessage — перевод конверта ошибки', () {
    http.Response res(int status, String body) => http.Response(
      body,
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    test('known codes become Russian messages', () {
      expect(
        apiMessage(res(401, '{"error":{"code":"UNAUTHORIZED","message":"x"}}')),
        'Неверный email или пароль',
      );
      expect(
        apiMessage(res(409, '{"error":{"code":"EMAIL_TAKEN","message":"x"}}')),
        'Аккаунт с этим email уже существует',
      );
      expect(
        apiMessage(
          res(400, '{"error":{"code":"VALIDATION_ERROR","message":"x"}}'),
        ),
        'Отправленные данные недействительны',
      );
      expect(
        apiMessage(res(404, '{"error":{"code":"NOT_FOUND","message":"x"}}')),
        'Запись не существует',
      );
    });

    test('unknown code and body outside the contract', () {
      expect(
        apiMessage(res(418, '{"error":{"code":"TEAPOT","message":"x"}}')),
        'Ошибка сервера (TEAPOT)',
      );
      expect(
        apiMessage(res(500, '<html>Internal error</html>')),
        'Ошибка сервера (500)',
      );
      expect(apiMessage(res(502, '[1, 2]')), 'Ошибка сервера (502)');
    });
  });

  test('TokenStore: save → read → clear', () async {
    SharedPreferences.setMockInitialValues({}); // prefs в памяти
    final tokens = TokenStore();
    expect(await tokens.read(), isNull); // не вошёл
    await tokens.save('eyJ.test.token');
    expect(await tokens.read(), 'eyJ.test.token');
    await tokens.clear();
    expect(await tokens.read(), isNull);
  });

  group('Login screen talks to AuthApi', () {
    setUpAll(() => router = buildRouter(initialLocation: '/login'));
    setUp(() => router.go('/login'));

    testWidgets('server error is shown in a SnackBar, user stays on login', (
      tester,
    ) async {
      await tester.pumpWidget(testApp(auth: RejectingAuthApi()));
      await tester.enterText(find.byType(TextFormField).at(0), 'a@test.md');
      await tester.enterText(find.byType(TextFormField).at(1), 'gresit1');
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      expect(find.text('Неверный email или пароль'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('register mode adds the name field and sends the name', (
      tester,
    ) async {
      final auth = RejectingAuthApi();
      await tester.pumpWidget(testApp(auth: auth));
      expect(find.byType(TextFormField), findsNWidgets(2));

      await tester.tap(find.text('Нет аккаунта? Зарегистрируйтесь'));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Зарегистрироваться'), findsOneWidget);

      // Без имени форма не уходит: валидатор ЛР3.
      await tester.enterText(find.byType(TextFormField).at(1), 'a@test.md');
      await tester.enterText(find.byType(TextFormField).at(2), 'parola123');
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();
      expect(auth.lastName, isNull);

      await tester.enterText(find.byType(TextFormField).at(0), 'Ana');
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();
      expect(auth.lastName, 'Ana');
      expect(find.text('Аккаунт с этим email уже существует'), findsOneWidget);

      // Обратно в режим входа — поле имени исчезает.
      await tester.tap(find.text('Уже есть аккаунт? Войдите'));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });
}
