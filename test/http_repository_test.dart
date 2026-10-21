import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bibly_app/data/http/api_client.dart';
import 'package:bibly_app/data/http/http_bible_repository.dart';
import 'package:bibly_app/data/http/http_daily_repository.dart';
import 'package:bibly_app/data/http/http_diary_repository.dart';
import 'package:bibly_app/data/result.dart';
import 'package:bibly_app/data/token_store.dart';
import 'package:bibly_app/models/daily_task.dart';
import 'package:bibly_app/models/diary_entry.dart';

/// Ответ «сервера» как у настоящего: JSON в UTF-8 БЕЗ charset в заголовке.
http.Response json(Object body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json'},
);

const _entry = {
  'id': 7,
  'title': 'Родиться свыше',
  'text': 'Никодим пришёл ночью',
  'dateLabel': '17 окт',
  'verseReference': 'Ин 3:3',
  'isPrivate': false,
  'createdAt': '2026-10-21T07:00:00Z',
};

void main() {
  late TokenStore tokens;
  late int unauthorizedCalls;
  late ApiClient api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'flutter.auth_token': 'eyJ.t.k'});
    tokens = TokenStore();
    unauthorizedCalls = 0;
    api = ApiClient(
      'http://server',
      tokens,
      onUnauthorized: () => unauthorizedCalls++,
    );
  });

  /// Запускает [body] так, что все http.get/post/... идут в [handler]
  /// вместо сети: настоящий код хранилища — подменён только «провод».
  Future<T> withServer<T>(
    Future<http.Response> Function(http.Request) handler,
    Future<T> Function() body,
  ) => http.runWithClient(body, () => MockClient(handler));

  test('fetchAll: Bearer в заголовке, список из конверта, кириллица', () async {
    late http.Request seen;
    final result = await withServer((req) async {
      seen = req;
      return json({
        'items': [_entry],
        'page': 1,
        'limit': 20,
        'total': 1,
      }, 200);
    }, () => HttpDiaryRepository(api).fetchAll());

    expect(seen.method, 'GET');
    expect(seen.url.toString(), 'http://server/entries');
    expect(seen.headers['Authorization'], 'Bearer eyJ.t.k');
    final list = (result as Ok<List<DiaryEntry>>).value;
    expect(list.single.title, 'Родиться свыше'); // не «Ð Ð¾Ð´…»
    expect(list.single.verseReference, 'Ин 3:3');
  });

  test('create: POST с toJson без id, 201 → запись с id сервера', () async {
    late Map<String, dynamic> sent;
    final result = await withServer(
      (req) async {
        sent = jsonDecode(req.body) as Map<String, dynamic>;
        return json(_entry, 201);
      },
      () => HttpDiaryRepository(api).create(
        const DiaryEntry(
          id: 0,
          title: 'Родиться свыше',
          text: 'x',
          dateLabel: '17 окт',
        ),
      ),
    );

    expect(sent.containsKey('id'), isFalse); // идентичность даёт сервер
    expect(sent['title'], 'Родиться свыше');
    expect((result as Ok<DiaryEntry>).value.id, 7);
  });

  test('delete: 204 с пустым телом → Ok без jsonDecode', () async {
    final result = await withServer(
      (req) async => http.Response('', 204),
      () => HttpDiaryRepository(api).delete(7),
    );
    expect(result, isA<Ok<void>>());
  });

  test('слой 2: 404 → переведённое сообщение из конверта', () async {
    final result = await withServer(
      (req) async => json({
        'error': {'code': 'NOT_FOUND', 'message': 'Entry not found'},
      }, 404),
      () => HttpDiaryRepository(api).fetchById(99),
    );
    expect((result as Err).msg, 'Запись не существует');
  });

  test('401: token стёрт, корень извещён, сообщение о сессии', () async {
    final result = await withServer(
      (req) async => json({
        'error': {'code': 'UNAUTHORIZED', 'message': 'x'},
      }, 401),
      () => HttpDiaryRepository(api).fetchAll(),
    );
    expect((result as Err).msg, 'Сессия истекла — войдите снова');
    expect(await tokens.read(), isNull);
    expect(unauthorizedCalls, 1);
  });

  test('слой 1: сервер недоступен → сообщение о сети', () async {
    final result = await withServer(
      (req) async => throw const SocketException('Connection refused'),
      () => HttpDiaryRepository(api).fetchAll(),
    );
    expect((result as Err).msg, 'Нет сети — повторите попытку');
  });

  test('слой 3: HTML вместо JSON → «Ответ не тот, что обещан»', () async {
    final result = await withServer(
      (req) async => http.Response('<html>proxy</html>', 200),
      () => HttpDiaryRepository(api).fetchAll(),
    );
    expect((result as Err).msg, 'Ответ не тот, что обещан');
  });

  test('слой 3: JSON другой формы → TypeError → тот же Err', () async {
    final result = await withServer(
      (req) async => json([1, 2, 3], 200), // список вместо конверта
      () => HttpDiaryRepository(api).fetchAll(),
    );
    expect((result as Err).msg, 'Ответ не тот, что обещан');
  });

  test('PATCH отметки и разбор вида пункта', () async {
    late http.Request seen;
    final result = await withServer((req) async {
      seen = req;
      return json({
        'id': 3,
        'title': 'Размышление',
        'subtitle': '',
        'minutes': 5,
        'type': 'reflection',
        'isDone': true,
      }, 200);
    }, () => HttpDailyRepository(api).setTaskDone(3, true));

    expect(seen.method, 'PATCH');
    expect(jsonDecode(seen.body), {'isDone': true});
    final task = (result as Ok<DailyTask>).value;
    expect(task.type, DailyTaskType.reflection);
    expect(task.isDone, isTrue);
  });

  test('поиск: кириллица в query кодируется в UTF-8', () async {
    late Uri seen;
    await withServer((req) async {
      seen = req.url;
      return json([], 200);
    }, () => HttpBibleRepository(api).search('любовь'));
    expect(seen.queryParameters['q'], 'любовь');
    expect(seen.query, contains('%D0%BB')); // «л» в UTF-8
  });
}
