// Проверка http-хранилищ против НАСТОЯЩЕГО сервера (server/).
// Обычный `flutter test` её пропускает; запуск при работающем сервере:
//   flutter test test/live_server_test.dart --dart-define=BIBLY_SERVER=http://localhost:8080
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bibly_app/data/auth_api.dart';
import 'package:bibly_app/data/http/api_client.dart';
import 'package:bibly_app/data/http/http_bible_repository.dart';
import 'package:bibly_app/data/http/http_community_repository.dart';
import 'package:bibly_app/data/http/http_daily_repository.dart';
import 'package:bibly_app/data/http/http_diary_repository.dart';
import 'package:bibly_app/data/http/http_profile_repository.dart';
import 'package:bibly_app/data/result.dart';
import 'package:bibly_app/data/token_store.dart';
import 'package:bibly_app/models/diary_entry.dart';

const server = String.fromEnvironment('BIBLY_SERVER');

/// Значение из Ok, иначе тест падает с текстом Err.
T ok<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Err(:final msg) => fail('Ожидался Ok, пришёл Err: $msg'),
};

void main() {
  group(
    'живой сервер',
    skip: server.isEmpty ? 'нет --dart-define=BIBLY_SERVER' : false,
    () {
      late TokenStore tokens;
      late ApiClient api;

      setUpAll(() async {
        SharedPreferences.setMockInitialValues({});
        tokens = TokenStore();
        final email = 'live${Random().nextInt(1 << 30)}@test.md';
        ok(await AuthApi(server, tokens).register(email, 'parola123', 'Live'));
        api = ApiClient(server, tokens);
      });

      test(
        'дневник: create → fetchAll → fetchById → update → delete',
        () async {
          final repo = HttpDiaryRepository(api);
          final created = ok(
            await repo.create(
              const DiaryEntry(
                id: 0,
                title: 'Родиться свыше',
                text: 'Никодим пришёл ночью',
                dateLabel: '17 окт',
                verseReference: 'Ин 3:3',
              ),
            ),
          );
          expect(created.id, greaterThan(0)); // id дал сервер
          expect(
            ok(await repo.fetchAll()).map((e) => e.id),
            contains(created.id),
          );
          expect(ok(await repo.fetchById(created.id)).title, 'Родиться свыше');
          final updated = ok(
            await repo.update(
              created.copyWith(text: 'обновлено', isPrivate: true),
            ),
          );
          expect(updated.isPrivate, isTrue);
          expect(await repo.delete(created.id), isA<Ok<void>>());
          expect(
            (await repo.fetchById(created.id) as Err).msg,
            'Запись не существует',
          );
        },
      );

      test('мой день: план и отметка', () async {
        final repo = HttpDailyRepository(api);
        final plan = ok(await repo.fetchToday());
        expect(plan.tasks, hasLength(4));
        expect(plan.verseOfDay.reference, 'Ин 3:16');
        expect(ok(await repo.setTaskDone(3, true)).isDone, isTrue);
      });

      test('Библия: книги, глава, поиск, история', () async {
        final repo = HttpBibleRepository(api);
        expect(ok(await repo.fetchBooks()), hasLength(66));
        final chapter = ok(await repo.fetchChapter(43, 3));
        expect(chapter.heading, 'Беседа Иисуса с Никодимом');
        expect(chapter.hasText, isTrue);
        expect(await repo.fetchChapter(43, 22), isA<Err>()); // 404
        expect(ok(await repo.search('любовь')), hasLength(7));
        expect(ok(await repo.fetchRecentSearches()), ['любовь']);
      });

      test('вместе: группы, лента, выход из группы', () async {
        final repo = HttpCommunityRepository(api);
        expect(ok(await repo.fetchGroups()), hasLength(6));
        expect(ok(await repo.fetchFeed()), hasLength(7));
        expect(await repo.leaveGroup(3), isA<Ok<void>>());
        expect(
          ok(await repo.fetchGroups()).map((g) => g.id),
          isNot(contains(3)),
        );
      });

      test('профиль: fetch и update', () async {
        final repo = HttpProfileRepository(api);
        final p = ok(await repo.fetch());
        expect(p.translation, 'Синодальный');
        final updated = ok(
          await repo.update(p.copyWith(about: 'Читаю Псалмы')),
        );
        expect(updated.about, 'Читаю Псалмы');
      });
    },
  );
}
