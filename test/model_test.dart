import 'package:flutter_test/flutter_test.dart';

import 'fakes/mock_diary_repository.dart';
import 'fakes/mock_network.dart';

import 'package:bibly_app/models/diary_entry.dart';
import 'package:bibly_app/models/diary_model.dart';

void main() {
  late MockNetwork net;
  late DiaryModel model;
  late int notifications;

  setUp(() {
    net = MockNetwork();
    // Модель получает хранилище через конструктор — в тесте подставляем mock.
    model = DiaryModel(MockDiaryRepository(net));
    notifications = 0;
    model.addListener(() => notifications++);
  });

  test('load: извещает при входе в «грузится» и при выходе', () async {
    final future = model.load();
    expect(model.isLoading, isTrue);
    expect(notifications, 1);
    await future;
    expect(model.isLoading, isFalse);
    expect(model.entries, hasLength(13));
    expect(notifications, 2);
  });

  test('коллекция наружу — только для чтения', () async {
    await model.load();
    const extra = DiaryEntry(id: 1, title: 't', text: 'x', dateLabel: 'd');
    expect(() => model.entries.add(extra), throwsUnsupportedError);
  });

  test('add: id от хранилища, извещение, null при успехе', () async {
    await model.load();
    notifications = 0;
    const draft = DiaryEntry(
      id: 0,
      title: 'Новая',
      text: 'Текст новой записи',
      dateLabel: 'сегодня',
    );
    expect(await model.add(draft), isNull);
    expect(model.entries.first.id, greaterThanOrEqualTo(1000));
    expect(notifications, 1);
  });

  test('ошибка хранилища: сообщение, состояние нетронуто', () async {
    await model.load();
    net.simulateError = true;
    notifications = 0;
    expect(await model.remove(1), MockNetwork.errNetwork);
    expect(model.byId(1), isNotNull);
    expect(notifications, 0);
  });

  group('ЛР5: страницы и поиск', () {
    /// 25 записей: полная первая страница (20) + хвост (5).
    List<DiaryEntry> many(int n) => [
      for (var i = 1; i <= n; i++)
        DiaryEntry(id: i, title: 'Запись $i', text: 'текст', dateLabel: ''),
    ];

    test('первая страница — 20, hasMore; loadMore приклеивает хвост', () async {
      final m = DiaryModel(MockDiaryRepository(net, seed: many(25)));
      await m.load();
      expect(m.entries, hasLength(DiaryModel.pageSize));
      expect(m.hasMore, isTrue);

      await m.loadMore();
      expect(m.entries, hasLength(25));
      expect(m.entries.last.id, 25);
      expect(m.hasMore, isFalse); // неполная страница → больше нет

      await m.loadMore(); // нечего просить — guard
      expect(m.entries, hasLength(25));
    });

    test('loadMore не извещает синхронно и не дублирует страницу', () async {
      final m = DiaryModel(MockDiaryRepository(net, seed: many(45)));
      await m.load();
      var calls = 0;
      m.addListener(() => calls++);

      // Два вызова подряд — как два build-а хвоста: второй отсекает guard.
      final a = m.loadMore();
      final b = m.loadMore();
      expect(calls, 0); // синхронного notifyListeners нет
      await Future.wait([a, b]);
      expect(m.entries, hasLength(40)); // одна страница, а не две
      expect(m.entries.map((e) => e.id).toSet(), hasLength(40));
      expect(calls, 1);
    });

    test('поиск: фильтр уходит в хранилище и переживает retry', () async {
      await model.load(search: 'ПАСТЫРЬ'); // регистр не важен
      expect(model.search, 'ПАСТЫРЬ');
      expect(model.entries.single.title, 'Господь — Пастырь мой');
      expect(model.hasMore, isFalse);

      await model.load(); // retry / pull-to-refresh — фильтр прежний
      expect(model.entries.single.title, 'Господь — Пастырь мой');

      await model.load(search: ''); // сброс поиска
      expect(model.entries, hasLength(13));
    });

    test(
      'ошибка следующей страницы — в moreError, retryMore повторяет',
      () async {
        final m = DiaryModel(MockDiaryRepository(net, seed: many(25)));
        await m.load();
        net.simulateError = true;
        await m.loadMore();
        expect(m.moreError, MockNetwork.errNetwork);
        expect(m.entries, hasLength(20)); // загруженное не потеряно

        net.simulateError = false;
        await m.retryMore();
        expect(m.moreError, isNull);
        expect(m.entries, hasLength(25));
      },
    );
  });
}
