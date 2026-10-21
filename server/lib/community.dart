// Bibly: "Вместе" — reading groups and the friends' feed.
//
//   GET    /groups                 -> [group] (groups the user has not left)
//   DELETE /groups/{id}/membership -> 204 | 404 (no such group / already left)
//   GET    /feed                    -> [activity]

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

/// GET /groups -> 200 [{id, name, members, plan, progress, memberNames}]
Future<Response> listGroups(Request request) async {
  final groups = db.select(
    'SELECT * FROM reading_groups WHERE id NOT IN '
    '(SELECT group_id FROM group_leaves WHERE user_id = ?) ORDER BY id',
    [currentUserId(request)],
  );
  return jsonResponse([
    for (final g in groups)
      {
        'id': g['id'],
        'name': g['name'],
        'members': g['members'],
        'plan': g['plan'],
        'progress': g['progress'],
        'memberNames': [
          for (final m in db.select(
            'SELECT name FROM group_members WHERE group_id = ? '
            'ORDER BY position',
            [g['id']],
          ))
            m['name'],
        ],
      },
  ]);
}

/// DELETE /groups/{id}/membership -> 204 | 404
/// "Not a member" and "no such group" look the same — like a foreign note.
Future<Response> leaveGroup(Request request) async {
  final userId = currentUserId(request);
  final id = int.tryParse(request.params['id'] ?? '');
  final isMember = id != null &&
      db.select(
        'SELECT 1 FROM reading_groups WHERE id = ? AND id NOT IN '
        '(SELECT group_id FROM group_leaves WHERE user_id = ?)',
        [id, userId],
      ).isNotEmpty;
  if (!isMember) return notFound('Group not found');

  db.execute(
    'INSERT INTO group_leaves (user_id, group_id) VALUES (?, ?)',
    [userId, id],
  );
  return Response(204);
}

/// GET /feed -> 200 [{name, action, timeLabel, sharedText, prayers}]
Future<Response> listFeed(Request request) async {
  final rows = db.select('SELECT * FROM feed ORDER BY id');
  return jsonResponse([
    for (final r in rows)
      {
        'name': r['name'],
        'action': r['action'],
        'timeLabel': r['time_label'],
        'sharedText': r['shared_text'],
        'prayers': r['prayers'],
      },
  ]);
}
