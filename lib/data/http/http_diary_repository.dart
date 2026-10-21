import '../../models/diary_entry.dart';
import '../diary_repository.dart';
import '../result.dart';
import 'api_client.dart';

/// Записи дневника на сервере — вторая реализация интерфейса ЛР4
/// (первая — MockDiaryRepository). Интерфейс не изменился ни на букву.
class HttpDiaryRepository implements DiaryRepository {
  HttpDiaryRepository(this._api);

  final ApiClient _api;

  /// Одна запись из JSON: разбор — fromJson сущности.
  static DiaryEntry _entry(Object? j) =>
      DiaryEntry.fromJson(j as Map<String, dynamic>);

  /// GET /entries → 200 {items, page, limit, total}: список — в items.
  @override
  Future<Result<List<DiaryEntry>>> fetchAll() => _api.get(
    '/entries',
    (j) => [
      for (final e in (j as Map<String, dynamic>)['items'] as List) _entry(e),
    ],
  );

  /// GET /entries/{id} → 200; 404 → Err через apiMessage.
  @override
  Future<Result<DiaryEntry>> fetchById(int id) =>
      _api.get('/entries/$id', _entry);

  /// POST /entries → 201: в ответе запись с id от сервера.
  @override
  Future<Result<DiaryEntry>> create(DiaryEntry entry) =>
      _api.post('/entries', entry.toJson(), _entry);

  /// PUT /entries/{id} → 200.
  @override
  Future<Result<DiaryEntry>> update(DiaryEntry entry) =>
      _api.put('/entries/${entry.id}', entry.toJson(), _entry);

  /// DELETE /entries/{id} → 204, тело пустое.
  @override
  Future<Result<void>> delete(int id) => _api.delete('/entries/$id');
}
