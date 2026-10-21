import '../models/diary_entry.dart';
import 'result.dart';

/// Контракт хранилища записей дневника: ЧТО можно просить, а не КАК.
/// На L5 каждый метод станет запросом к REST API:
///   fetchAll(...)   → GET    /entries?page=&limit=&search=
///                     (с ЛР5: страница и поиск — на сервере)
///   fetchById(id)   → GET    /entries/{id}   (Err при 404)
///   create(entry)   → POST   /entries        (201, id даёт сервер)
///   update(entry)   → PUT    /entries/{id}
///   delete(id)      → DELETE /entries/{id}   (204 → `Result<void>`)
abstract class DiaryRepository {
  /// Интерфейс растёт совместимо: параметры именованные и необязательные,
  /// поэтому старый вызов fetchAll() из ЛР4 компилируется без изменений.
  Future<Result<List<DiaryEntry>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<Result<DiaryEntry>> fetchById(int id);
  Future<Result<DiaryEntry>> create(DiaryEntry entry);
  Future<Result<DiaryEntry>> update(DiaryEntry entry);
  Future<Result<void>> delete(int id);
}
