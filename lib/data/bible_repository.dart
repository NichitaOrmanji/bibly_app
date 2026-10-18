import '../models/bible_book.dart';
import '../models/chapter_text.dart';
import '../models/verse.dart';
import 'result.dart';

/// Контракт хранилища Библии (только чтение).
///   fetchBooks()               → GET /books
///   fetchChapter(book, number) → GET /books/{id}/chapters/{n} (Err при 404)
///   search(query)              → GET /search?q=...
abstract class BibleRepository {
  Future<Result<List<BibleBook>>> fetchBooks();
  Future<Result<ChapterText>> fetchChapter(int bookId, int chapter);
  Future<Result<List<Verse>>> search(String query);
}
