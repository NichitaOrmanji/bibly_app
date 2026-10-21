import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../api_message.dart';
import '../result.dart';
import '../token_store.dart';

/// Превращает JSON ответа в объект приложения (обычно — вызов fromJson).
typedef Parse<T> = T Function(Object? json);

/// Общий скелет каждого запроса http-хранилищ — написан один раз, а не
/// пятнадцать: token в заголовке, timeout, вердикт по статусу, 401,
/// разбор JSON и три слоя отказа, сведённые в [Result].
///
/// Хранилища (HttpDiaryRepository и др.) говорят только «какой адрес,
/// какой хороший статус, как разобрать ответ».
class ApiClient {
  ApiClient(this.baseUrl, this.tokens, {this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokens;

  /// Что делать, когда сервер ответил 401. Решает корень композиции
  /// (на L5 — увести на вход); хранилище router не знает.
  final void Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 8);

  Future<Result<T>> get<T>(
    String path,
    Parse<T> parse, {
    Map<String, String>? query,
  }) => _send(
    () async => http.get(_uri(path, query), headers: await _headers()),
    200,
    parse,
  );

  Future<Result<T>> post<T>(String path, Object body, Parse<T> parse) => _send(
    () async => http.post(
      _uri(path),
      headers: await _headers(),
      body: jsonEncode(body),
    ),
    201, // создано: id дал сервер
    parse,
  );

  Future<Result<T>> put<T>(String path, Object body, Parse<T> parse) => _send(
    () async =>
        http.put(_uri(path), headers: await _headers(), body: jsonEncode(body)),
    200,
    parse,
  );

  Future<Result<T>> patch<T>(String path, Object body, Parse<T> parse) => _send(
    () async => http.patch(
      _uri(path),
      headers: await _headers(),
      body: jsonEncode(body),
    ),
    200,
    parse,
  );

  /// DELETE: хороший статус — 204, тело пустое, разбирать нечего.
  Future<Result<void>> delete(String path) => _send(
    () async => http.delete(_uri(path), headers: await _headers()),
    204,
    (_) {},
  );

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Future<Map<String, String>> _headers() async => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await tokens.read() ?? ''}', // пропуск
  };

  /// 401 = пропуск умер: выбросить его из prefs и известить корень.
  Future<String> _sessionDied() async {
    await tokens.clear();
    onUnauthorized?.call();
    return 'Сессия истекла — войдите снова';
  }

  /// Читать сверху вниз — три слоя отказа:
  ///  1. дорога упала (нет сети, сервер молчит) — БРОСАЕТ, ловим по типу;
  ///  2. сервер ответил «нет» (404, 400…) — НЕ бросает, читаем statusCode
  ///     и переводим конверт через apiMessage;
  ///  3. тело-сюрприз (HTML, чужой JSON) — бросает при разборе:
  ///     FormatException от jsonDecode, TypeError от cast-ов в fromJson.
  /// Все ветки сходятся в Err(msg) — экран знает только Result.
  Future<Result<T>> _send<T>(
    Future<http.Response> Function() request,
    int ok,
    Parse<T> parse,
  ) async {
    try {
      final res = await request().timeout(_timeout); // timeout — на КАЖДОМ
      if (res.statusCode == 401) return Err(await _sessionDied());
      if (res.statusCode != ok) return Err(apiMessage(res)); // слой 2
      // 204 — тело пустое: jsonDecode('') бросил бы FormatException.
      // utf8 — явно: сервер не пишет charset, и res.body прочёл бы
      // кириллицу как latin1 («ÐÑ…» вместо «Ин»).
      final json = res.statusCode == 204
          ? null
          : jsonDecode(utf8.decode(res.bodyBytes));
      return Ok(parse(json));
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
