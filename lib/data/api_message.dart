import 'dart:convert';

import 'package:http/http.dart' as http;

/// Переводит ответ-ошибку сервера в сообщение для человека — в одном месте.
///
/// Контракт обещает на любой ошибке тело {"error": {"code", "message"}}.
/// code стабилен и принадлежит программе; английский message на экран
/// не попадает — русский текст выбираем здесь по code.
/// Тело вне контракта (HTML от прокси, 500 без JSON) → «Ошибка сервера».
String apiMessage(http.Response res) {
  try {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final code = (body['error'] as Map<String, dynamic>)['code'] as String;
    return switch (code) {
      'VALIDATION_ERROR' => 'Отправленные данные недействительны',
      'UNAUTHORIZED' => 'Неверный email или пароль',
      'EMAIL_TAKEN' => 'Аккаунт с этим email уже существует',
      'NOT_FOUND' => 'Запись не существует',
      _ => 'Ошибка сервера ($code)',
    };
  } on FormatException {
    return 'Ошибка сервера (${res.statusCode})'; // тело — не JSON
  } on TypeError {
    return 'Ошибка сервера (${res.statusCode})'; // JSON, но не конверт
  }
}
