import '../../models/diary_entry.dart';
import '../diary_repository.dart';
import '../mock_data.dart';
import '../result.dart';
import 'mock_network.dart';

/// Записи дневника в памяти — с повадками сети (задержка + авария).
class MockDiaryRepository implements DiaryRepository {
  MockDiaryRepository(this._net);

  final MockNetwork _net;

  // Seed из ЛР2: открытые записи Дневника и личные записи Скинии.
  final List<DiaryEntry> _entries = [
    ...MockData.diaryEntries,
    ...MockData.tabernacleEntries,
  ];
  int _nextId = 1000; // выше любого id из seed-а

  static const _errNotFound = 'Запись не существует';

  @override
  Future<Result<List<DiaryEntry>>> fetchAll() async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    return Ok(List.of(_entries)); // копия — внутренность не отдаётся из рук
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
