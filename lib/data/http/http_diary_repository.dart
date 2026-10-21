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

  /// GET /entries?page=&limit=&search= → 200 {items, page, limit, total}:
  /// сервер сам режет страницу и ищет — телефон получает только свой ломоть.
  @override
  Future<Result<List<DiaryEntry>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
  }) => _api.get(
    '/entries',
    (j) => [
      for (final e in (j as Map<String, dynamic>)['items'] as List) _entry(e),
    ],
    query: {
      'page': '$page',
      'limit': '$limit',
      if (search != null && search.isNotEmpty) 'search': search,
    },
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
