// Bibly: the Bible (read-only) and per-user search history.
//
//   GET /books                     -> [book]
//   GET /books/{id}/chapters/{n}   -> {bookId, chapter, heading, verses} | 404
//   GET /search?q=                 -> [{text, reference}] (query is remembered)
//   GET /me/searches               -> [query] (last 6, newest first)

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

/// GET /books -> 200 [{id, name, abbreviation, chapters, testament}]
Future<Response> listBooks(Request request) async {
  final rows = db.select('SELECT * FROM books ORDER BY id');
  return jsonResponse([
    for (final b in rows)
      {
        'id': b['id'],
        'name': b['name'],
        'abbreviation': b['abbreviation'],
        'chapters': b['chapters'],
        'testament': b['testament'],
      },
  ]);
}

/// GET /books/{id}/chapters/{n} -> 200 chapter | 404
/// A chapter that exists but has no text yet comes back with verses: [].
Future<Response> getChapter(Request request) async {
  final bookId = int.tryParse(request.params['id'] ?? '');
  final chapter = int.tryParse(request.params['n'] ?? '');
  final book = bookId == null
      ? const []
      : db.select('SELECT chapters FROM books WHERE id = ?', [bookId]);
  if (book.isEmpty ||
      chapter == null ||
      chapter < 1 ||
      chapter > (book.first['chapters'] as int)) {
    return notFound('Chapter not found');
  }

  final heading = db.select(
    'SELECT heading FROM chapter_headings WHERE book_id = ? AND chapter = ?',
    [bookId, chapter],
  );
  final verses = db.select(
    'SELECT * FROM verses WHERE book_id = ? AND chapter = ? ORDER BY number',
    [bookId, chapter],
  );
  return jsonResponse({
    'bookId': bookId,
    'chapter': chapter,
    'heading': heading.isEmpty ? null : heading.first['heading'],
    'verses': [
      for (final v in verses)
        {
          'number': v['number'],
          'text': v['text'],
          'isHighlighted': v['highlighted'] == 1,
        },
    ],
  });
}

/// GET /search?q= -> 200 [{text, reference}]
/// Finds verses by a word stem («любовь» -> «люб»: also «любит», «любви»)
/// or by a reference («Ин 3:16»). Filtering runs in Dart, not in SQL:
/// SQLite lower()/LIKE ignore case only for ASCII, not for Cyrillic.
Future<Response> searchVerses(Request request) async {
  final query = (request.url.queryParameters['q'] ?? '').trim();
  if (query.isEmpty) return jsonResponse(const []);

  db.execute(
    'INSERT INTO searches (user_id, query, created_at) VALUES (?, ?, ?)',
    [currentUserId(request), query, nowIso()],
  );

  final q = query.toLowerCase();
  // A query with digits is a reference («Ин 3:16») — no stem search then,
  // otherwise «ин » would also match «один из» in the text.
  final isReference = q.contains(RegExp(r'\d'));
  final stem = q.length > 3 ? q.substring(0, 3) : q;
  final rows = db.select(
    'SELECT v.*, b.abbreviation FROM verses v '
    'JOIN books b ON b.id = v.book_id ORDER BY v.book_id, v.chapter, v.number',
  );
  return jsonResponse([
    for (final v in rows)
      if ((!isReference &&
              (v['text'] as String).toLowerCase().contains(stem)) ||
          _reference(v).toLowerCase() == q ||
          _reference(v).toLowerCase().startsWith('$q:'))
        {'text': v['text'], 'reference': _reference(v)},
  ]);
}

String _reference(Map<String, Object?> v) =>
    '${v['abbreviation']} ${v['chapter']}:${v['number']}';

/// GET /me/searches -> 200 [query] — the user's last 6 distinct queries.
Future<Response> recentSearches(Request request) async {
  final rows = db.select(
    'SELECT query FROM searches WHERE user_id = ? '
    'GROUP BY query ORDER BY MAX(id) DESC LIMIT 6',
    [currentUserId(request)],
  );
  return jsonResponse([for (final r in rows) r['query']]);
}
