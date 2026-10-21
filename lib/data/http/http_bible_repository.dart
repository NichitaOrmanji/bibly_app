import '../../models/bible_book.dart';
import '../../models/chapter_text.dart';
import '../../models/verse.dart';
import '../bible_repository.dart';
import '../result.dart';
import 'api_client.dart';

/// Библия на сервере (только чтение) и история поиска пользователя.
class HttpBibleRepository implements BibleRepository {
  HttpBibleRepository(this._api);

  final ApiClient _api;

  /// GET /books → список из 66 книг.
  @override
  Future<Result<List<BibleBook>>> fetchBooks() => _api.get(
    '/books',
    (j) => [
      for (final b in j as List) BibleBook.fromJson(b as Map<String, dynamic>),
    ],
  );

  /// GET /books/{id}/chapters/{n}; глава вне книги → 404 → Err.
  @override
  Future<Result<ChapterText>> fetchChapter(int bookId, int chapter) => _api.get(
    '/books/$bookId/chapters/$chapter',
    (j) => ChapterText.fromJson(j as Map<String, dynamic>),
  );

  /// GET /search?q= — ищет СЕРВЕР; запрос попадает в историю.
  /// Пустой запрос до сервера не доходит.
  @override
  Future<Result<List<Verse>>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const Ok([]);
    return _api.get(
      '/search',
      (j) => [
        for (final v in j as List) Verse.fromJson(v as Map<String, dynamic>),
      ],
      query: {'q': q}, // Uri сам закодирует кириллицу в UTF-8
    );
  }

  /// GET /me/searches → последние запросы, новые сверху.
  @override
  Future<Result<List<String>>> fetchRecentSearches() =>
      _api.get('/me/searches', (j) => [for (final q in j as List) q as String]);
}
