// Bibly: diary entries, scoped per user. A copy of notes.dart with other
// nouns: list with pagination/search, create with validation (400),
// get/put/delete with 404.
//
// Private entries (isPrivate = true) belong to "Скиния" — the app shows
// them only after the PIN; for the server they are ordinary rows.

import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

Map<String, Object?> _toJson(Row row) => {
      'id': row['id'],
      'title': row['title'],
      'text': row['text'],
      'dateLabel': row['date_label'],
      'verseReference': row['verse_reference'],
      'isPrivate': row['is_private'] == 1,
      'createdAt': row['created_at'],
    };

/// Finds an entry by id, but only among the current user's entries.
/// Someone else's entry is indistinguishable from a missing one (404).
Row? _find(int userId, String? idParam) {
  final id = int.tryParse(idParam ?? '');
  if (id == null) return null;
  final rows = db.select(
    'SELECT * FROM entries WHERE id = ? AND user_id = ?',
    [id, userId],
  );
  return rows.isEmpty ? null : rows.first;
}

/// Validated fields of a create/update body, or the 400 to send back.
typedef _Fields = ({
  String title,
  String text,
  String dateLabel,
  String? verseReference,
  bool isPrivate,
});

(_Fields?, Response?) _readFields(Map<String, dynamic>? body) {
  if (body == null) return (null, validationError('Body must be a JSON object'));
  final title = stringField(body, 'title');
  if (title == null) return (null, validationError('title is required'));
  final isPrivate = body['isPrivate'] ?? false;
  if (isPrivate is! bool) {
    return (null, validationError('isPrivate must be a boolean'));
  }
  return (
    (
      title: title,
      text: body['text'] is String ? body['text'] as String : '',
      dateLabel: stringField(body, 'dateLabel') ?? '',
      verseReference: stringField(body, 'verseReference'),
      isPrivate: isPrivate,
    ),
    null,
  );
}

String _searchText(_Fields f) =>
    '${f.title} ${f.text} ${f.verseReference ?? ''}'.toLowerCase();

/// GET /entries?page=1&limit=20&search=  -> {items, page, limit, total}
Future<Response> listEntries(Request request) async {
  final query = request.url.queryParameters;
  final page = max(int.tryParse(query['page'] ?? '') ?? 1, 1);
  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100);
  final search = (query['search'] ?? '').toLowerCase();

  const where = 'user_id = ? AND search_text LIKE ?';
  final args = [currentUserId(request), '%$search%'];

  final total =
      db.select('SELECT COUNT(*) AS n FROM entries WHERE $where', args)
          .first['n'] as int;
  final rows = db.select(
    'SELECT * FROM entries WHERE $where ORDER BY id DESC LIMIT ? OFFSET ?',
    [...args, limit, (page - 1) * limit],
  );

  return jsonResponse({
    'items': rows.map(_toJson).toList(),
    'page': page,
    'limit': limit,
    'total': total,
  });
}

/// POST /entries  {title, text, dateLabel, verseReference, isPrivate}
/// -> 201 entry (id is given by the server)
Future<Response> createEntry(Request request) async {
  final (f, error) = _readFields(await readJsonBody(request));
  if (error != null) return error;

  db.execute(
    'INSERT INTO entries (user_id, title, text, date_label, verse_reference, '
    'is_private, search_text, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [
      currentUserId(request),
      f!.title,
      f.text,
      f.dateLabel,
      f.verseReference,
      f.isPrivate ? 1 : 0,
      _searchText(f),
      nowIso(),
    ],
  );
  final row = _find(currentUserId(request), '${db.lastInsertRowId}')!;
  return jsonResponse(_toJson(row), status: 201);
}

/// GET /entries/{id} -> 200 entry | 404
Future<Response> getEntry(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Entry not found');
  return jsonResponse(_toJson(row));
}

/// PUT /entries/{id}  {title, text, ...} -> 200 updated entry | 404
Future<Response> updateEntry(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Entry not found');

  final (f, error) = _readFields(await readJsonBody(request));
  if (error != null) return error;

  db.execute(
    'UPDATE entries SET title = ?, text = ?, date_label = ?, '
    'verse_reference = ?, is_private = ?, search_text = ? WHERE id = ?',
    [
      f!.title,
      f.text,
      f.dateLabel,
      f.verseReference,
      f.isPrivate ? 1 : 0,
      _searchText(f),
      row['id'],
    ],
  );
  final updated = _find(currentUserId(request), '${row['id']}')!;
  return jsonResponse(_toJson(updated));
}

/// DELETE /entries/{id} -> 204 | 404
Future<Response> deleteEntry(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Entry not found');
  db.execute('DELETE FROM entries WHERE id = ?', [row['id']]);
  return Response(204);
}
