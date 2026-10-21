import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

/// Регистрация и вход по контракту сервера; полученный token уходит
/// в [TokenStore].
///   register → POST /auth/register {email, password, name} → 201 {token, user}
///   login    → POST /auth/login    {email, password}       → 200 {token, user}
class AuthApi {
  AuthApi(this.baseUrl, this.tokens);

  final String baseUrl;
  final TokenStore tokens;

  static const _timeout = Duration(seconds: 8);

  /// Номер сеанса: растёт при каждом успешном входе/регистрации.
  /// Корень по нему пересоздаёт модели — данные прошлого пользователя
  /// не переживают выход, новые грузятся с новым token-ом.
  final session = ValueNotifier<int>(0);

  Future<Result<void>> register(String email, String password, String name) =>
      _post('/auth/register', {
        'email': email,
        'password': password,
        'name': name,
      });

  Future<Result<void>> login(String email, String password) =>
      _post('/auth/login', {'email': email, 'password': password});

  /// Выход — просто выбросить пропуск; сервер о выходе не узнаёт.
  Future<void> logout() => tokens.clear();

  /// register и login разнятся лишь путём и телом — общий запрос.
  /// Три слоя отказа: дорога (исключения), ответ сервера (statusCode),
  /// тело-сюрприз (ошибка разбора) — всё сходится в Err(msg).
  Future<Result<void>> _post(String path, Map<String, Object?> body) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      if (res.statusCode != 200 && res.statusCode != 201) {
        return Err(apiMessage(res)); // слой 2: 400 / 401 / 409 из конверта
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await tokens.save(data['token'] as String); // пропуск — в prefs
      session.value++; // новый сеанс — свежие модели
      return const Ok(null);
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    }
  }
}
