// Bibly: "Мой день" — today's plan (shared) with per-user "done" marks.
//
//   GET   /plans/today             -> {dateLabel, verseOfDay, tasks}
//   PATCH /plans/today/tasks/{id}  {isDone} -> 200 task | 400 | 404

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

/// Tasks with the current user's mark: LEFT JOIN -> done when a row exists.
const _taskSelect = '''
  SELECT t.*, (d.task_id IS NOT NULL) AS is_done
  FROM daily_tasks t
  LEFT JOIN task_done d ON d.task_id = t.id AND d.user_id = ?
''';

Map<String, Object?> _taskJson(Row row) => {
      'id': row['id'],
      'title': row['title'],
      'subtitle': row['subtitle'],
      'minutes': row['minutes'],
      'type': row['type'],
      'isDone': row['is_done'] == 1,
    };

/// GET /plans/today -> 200 {dateLabel, verseOfDay: {text, reference}, tasks}
Future<Response> getToday(Request request) async {
  final plan = db.select('SELECT * FROM day_plan WHERE id = 1');
  if (plan.isEmpty) return notFound('No plan for today');
  final tasks = db.select(
    '$_taskSelect ORDER BY t.position',
    [currentUserId(request)],
  );
  return jsonResponse({
    'dateLabel': plan.first['date_label'],
    'verseOfDay': {
      'text': plan.first['verse_text'],
      'reference': plan.first['verse_ref'],
    },
    'tasks': tasks.map(_taskJson).toList(),
  });
}

/// PATCH /plans/today/tasks/{id}  {isDone: bool} -> 200 task | 400 | 404
Future<Response> setTaskDone(Request request) async {
  final userId = currentUserId(request);
  final id = int.tryParse(request.params['id'] ?? '');
  final exists = id != null &&
      db.select('SELECT 1 FROM daily_tasks WHERE id = ?', [id]).isNotEmpty;
  if (!exists) return notFound('Task not found');

  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final isDone = body['isDone'];
  if (isDone is! bool) return validationError('isDone must be a boolean');

  if (isDone) {
    db.execute(
      'INSERT OR IGNORE INTO task_done (user_id, task_id) VALUES (?, ?)',
      [userId, id],
    );
  } else {
    db.execute(
      'DELETE FROM task_done WHERE user_id = ? AND task_id = ?',
      [userId, id],
    );
  }
  final row = db.select('$_taskSelect WHERE t.id = ?', [userId, id]).first;
  return jsonResponse(_taskJson(row));
}
