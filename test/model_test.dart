import 'package:flutter_test/flutter_test.dart';

import 'package:bibly_app/data/mock/mock_diary_repository.dart';
import 'package:bibly_app/data/mock/mock_network.dart';
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
}
