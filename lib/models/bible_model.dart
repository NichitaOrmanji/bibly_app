import 'package:flutter/foundation.dart';

import '../data/bible_repository.dart';
import '../data/result.dart';
import 'bible_book.dart';
import 'chapter_text.dart';
import 'verse.dart';

/// Библия: список книг, загруженные главы и результаты поиска.
/// У каждой части — своя триада «грузится / ошибка / данные».
class BibleModel extends ChangeNotifier {
  BibleModel(this._repository);

  final BibleRepository _repository;

  // ---------- Книги ----------
  bool _loading = false;
  String? _error;
  List<BibleBook> _books = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<BibleBook> get books => List.unmodifiable(_books);

  BibleBook? byId(int id) {
    for (final b in _books) {
      if (b.id == id) return b;
    }
    return null;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    // Книги и недавние запросы — параллельно.
    final (books, recent) = await (
      _repository.fetchBooks(),
      _repository.fetchRecentSearches(),
    ).wait;
    switch ((books, recent)) {
      case (Ok(value: final b), Ok(value: final r)):
        _books = b;
        _recent = r;
      case (Err(:final msg), _) || (_, Err(:final msg)):
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  // ---------- Главы (кэш по ключу «книга:глава») ----------
  final Map<String, ChapterText> _chapters = {};
  final Set<String> _chapterLoading = {};
  final Map<String, String> _chapterErrors = {};

  static String _key(int bookId, int chapter) => '$bookId:$chapter';

  ChapterText? chapter(int bookId, int chapter) =>
      _chapters[_key(bookId, chapter)];
  bool isChapterLoading(int bookId, int chapter) =>
      _chapterLoading.contains(_key(bookId, chapter));
  String? chapterError(int bookId, int chapter) =>
      _chapterErrors[_key(bookId, chapter)];

  Future<void> loadChapter(int bookId, int chapter) async {
    final key = _key(bookId, chapter);
    _chapterLoading.add(key);
    _chapterErrors.remove(key);
    notifyListeners();
    switch (await _repository.fetchChapter(bookId, chapter)) {
      case Ok(:final value):
        _chapters[key] = value;
      case Err(:final msg):
        _chapterErrors[key] = msg;
    }
    _chapterLoading.remove(key);
    notifyListeners();
  }

  // ---------- Поиск ----------
  bool _searching = false;
  String? _searchError;
  String _query = '';
  List<Verse> _results = const [];
  List<String> _recent = const [];

  bool get isSearching => _searching;
  String? get searchError => _searchError;
  String get query => _query;
  List<Verse> get results => List.unmodifiable(_results);
  List<String> get recentSearches => List.unmodifiable(_recent);

  Future<void> search(String query) async {
    _query = query.trim();
    _searching = true;
    _searchError = null;
    notifyListeners();
    switch (await _repository.search(_query)) {
      case Ok(:final value):
        _results = value;
        // Удачный запрос — в начало «недавних», без повторов, не больше 8.
        _recent = [
          _query,
          ..._recent.where((q) => q != _query),
        ].take(8).toList();
      case Err(:final msg):
        _searchError = msg;
    }
    _searching = false;
    notifyListeners();
  }
}
