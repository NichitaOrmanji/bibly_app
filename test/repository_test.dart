import 'package:flutter_test/flutter_test.dart';

import 'fakes/mock_bible_repository.dart';
import 'fakes/mock_diary_repository.dart';
import 'fakes/mock_network.dart';

import 'package:bibly_app/data/result.dart';
import 'package:bibly_app/models/diary_entry.dart';

void main() {
  late MockNetwork net;
  late MockDiaryRepository diary;

  setUp(() {
    net = MockNetwork();
    diary = MockDiaryRepository(net);
  });

  test('create: id даёт хранилище, запись появляется в fetchAll', () async {
    const draft = DiaryEntry(
      id: 0,
      title: 'Тест',
      text: 'Текст записи',
      dateLabel: 'сегодня',
    );
    final created = await diary.create(draft);
    expect(created, isA<Ok<DiaryEntry>>());
    final entry = (created as Ok<DiaryEntry>).value;
    expect(entry.id, greaterThanOrEqualTo(1000));

    final all = await diary.fetchAll() as Ok<List<DiaryEntry>>;
    expect(all.value.first.id, entry.id);
  });

  test('delete и fetchById: несуществующий id → Err («404»)', () async {
    expect(await diary.delete(1), isA<Ok<void>>());
    expect(await diary.delete(1), isA<Err<void>>());
    expect(await diary.fetchById(1), isA<Err<DiaryEntry>>());
  });

  test('авария: любой вызов возвращает Err с сообщением', () async {
    net.simulateError = true;
    final r = await diary.fetchAll();
    expect(r, isA<Err<List<DiaryEntry>>>());
    expect((r as Err).msg, MockNetwork.errNetwork);

    net.simulateError = false;
    expect(await diary.fetchAll(), isA<Ok<List<DiaryEntry>>>());
  });

  test('поиск по основе слова и глава, которой нет', () async {
    final bible = MockBibleRepository(net);
    final found = await bible.search('любовь') as Ok;
    expect((found.value as List).length, greaterThanOrEqualTo(6));
    expect(await bible.fetchChapter(43, 22), isA<Err>());
  });
}
