import 'package:bibly_app/data/diary_repository.dart';
import 'package:bibly_app/data/result.dart';
import 'package:bibly_app/models/diary_entry.dart';

import 'mock_data.dart';
import 'mock_network.dart';

/// Записи дневника в памяти — с повадками сети (задержка + авария).
class MockDiaryRepository implements DiaryRepository {
  /// [seed] — свои записи для теста (например, 30 штук для пагинации);
  /// по умолчанию — seed из ЛР2.
  MockDiaryRepository(this._net, {List<DiaryEntry>? seed})
    : _entries = List.of(
        seed ?? [...MockData.diaryEntries, ...MockData.tabernacleEntries],
      );

  final MockNetwork _net;
  final List<DiaryEntry> _entries;
  int _nextId = 1000; // выше любого id из seed-а

  static const _errNotFound = 'Запись не существует';

  /// Как сервер: поиск без учёта регистра по заголовку, тексту и стиху,
  /// затем страница [page] по [limit] штук.
  @override
  Future<Result<List<DiaryEntry>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    final q = (search ?? '').toLowerCase();
    final found = _entries.where(
      (e) => '${e.title} ${e.text} ${e.verseReference ?? ''}'
          .toLowerCase()
          .contains(q),
    );
    // копия — внутренность не отдаётся из рук
    return Ok(found.skip((page - 1) * limit).take(limit).toList());
  }

  @override
  Future<Result<DiaryEntry>> fetchById(int id) async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    final i = _entries.indexWhere((e) => e.id == id);
    if (i == -1) return const Err(_errNotFound); // «404» mock-а
    return Ok(_entries[i]);
  }

  @override
  Future<Result<DiaryEntry>> create(DiaryEntry entry) async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    // Идентичность даёт ХРАНИЛИЩЕ (на L5 — сервер), а не форма.
    final created = entry.copyWith(id: _nextId++);
    _entries.insert(0, created); // новые записи — сверху
    return Ok(created);
  }

  @override
  Future<Result<DiaryEntry>> update(DiaryEntry entry) async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    final i = _entries.indexWhere((e) => e.id == entry.id);
    if (i == -1) return const Err(_errNotFound);
    _entries[i] = entry;
    return Ok(entry);
  }

  @override
  Future<Result<void>> delete(int id) async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    final before = _entries.length;
    _entries.removeWhere((e) => e.id == id);
    if (_entries.length == before) return const Err(_errNotFound);
    return const Ok(null); // «удалил, отдать нечего» — 204
  }
}
