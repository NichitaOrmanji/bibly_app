import '../../models/bible_book.dart';
import '../../models/chapter_text.dart';
import '../../models/verse.dart';
import '../bible_repository.dart';
import '../mock_data.dart';
import '../result.dart';
import 'mock_network.dart';

/// Библия в памяти: 66 книг, текст одной главы (Ин 3) и поиск.
class MockBibleRepository implements BibleRepository {
  MockBibleRepository(this._net);

  final MockNetwork _net;

  @override
  Future<Result<List<BibleBook>>> fetchBooks() async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    return Ok(List.of(MockData.books));
  }

  @override
  Future<Result<ChapterText>> fetchChapter(int bookId, int chapter) async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    final books = MockData.books.where((b) => b.id == bookId);
    if (books.isEmpty || chapter < 1 || chapter > books.first.chapters) {
      return const Err('Глава не существует'); // «404» mock-а
    }
    // Текст в seed-е есть только у Ин 3; у остальных глав — пустой текст.
    final hasSeed =
        bookId == MockData.user.lastReadBookId &&
        chapter == MockData.user.lastReadChapter;
    return Ok(
      ChapterText(
        bookId: bookId,
        chapter: chapter,
        heading: hasSeed ? MockData.chapterHeading : null,
        verses: hasSeed ? MockData.chapterVerses : const [],
      ),
    );
  }

  @override
  Future<Result<List<Verse>>> search(String query) async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const Ok([]);
    // Упрощённый поиск по основе слова: «любовь» находит и «любит», и «любви».
    final stem = q.length > 3 ? q.substring(0, 3) : q;
    final all = <Verse>[
      ...MockData.searchResults,
      for (final v in MockData.chapterVerses)
        Verse(text: v.text, reference: 'Ин 3:${v.number}'),
    ];
    final seen = <String>{};
    return Ok([
      for (final v in all)
        if ((v.text.toLowerCase().contains(stem) ||
                v.reference.toLowerCase().contains(q)) &&
            seen.add(v.reference))
          v,
    ]);
  }
}
