import '../models/diary_entry.dart';
import 'result.dart';

/// Контракт хранилища записей дневника: ЧТО можно просить, а не КАК.
/// На L5 каждый метод станет запросом к REST API:
///   fetchAll()      → GET    /entries
///   fetchById(id)   → GET    /entries/{id}   (Err при 404)
///   create(entry)   → POST   /entries        (201, id даёт сервер)
///   update(entry)   → PUT    /entries/{id}
///   delete(id)      → DELETE /entries/{id}   (204 → `Result<void>`)
abstract class DiaryRepository {
  Future<Result<List<DiaryEntry>>> fetchAll();
  Future<Result<DiaryEntry>> fetchById(int id);
  Future<Result<DiaryEntry>> create(DiaryEntry entry);
  Future<Result<DiaryEntry>> update(DiaryEntry entry);
  Future<Result<void>> delete(int id);
}
