// Bibly: the user's profile — the second writable entity.
//
//   GET /profile                          -> 200 profile
//   PUT /profile {name, email, phone, about} -> 200 profile | 400 | 409
//
// The base contract's GET /me ({id, email, name}) stays untouched;
// /profile is the Bibly superset with statistics and settings.

import 'package:shelf/shelf.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

const _months = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля',
  'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

/// The user row joined with their profile row (created with defaults
/// on first access, so the SELECT always finds one).
Map<String, Object?> _load(int userId) {
  db.execute('INSERT OR IGNORE INTO profiles (user_id) VALUES (?)', [userId]);
  final r = db.select(
    'SELECT u.name, u.email, u.created_at, p.* FROM users u '
    'JOIN profiles p ON p.user_id = u.id WHERE u.id = ?',
    [userId],
  ).first;
  final since = DateTime.parse(r['created_at'] as String);
  return {
    'name': r['name'],
    'email': r['email'],
    'phone': r['phone'],
    'about': r['about'],
    'memberSince': 'с ${_months[since.month - 1]} ${since.year}',
    'streakDays': r['streak_days'],
    'chaptersRead': r['chapters_read'],
    'lastReadBookId': r['last_book_id'],
    'lastReadChapter': r['last_chapter'],
    'translation': r['translation'],
    'textSize': r['text_size'],
    'reminderTime': r['reminder_time'],
    'reminderOn': r['reminder_on'] == 1,
    'shareWithGroup': r['share_with_group'] == 1,
    'language': r['language'],
  };
}

/// GET /profile -> 200 profile
Future<Response> getProfile(Request request) async =>
    jsonResponse(_load(currentUserId(request)));

/// PUT /profile {name, email, phone, about} -> 200 profile | 400 | 409
Future<Response> updateProfile(Request request) async {
  final userId = currentUserId(request);
  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final name = stringField(body, 'name');
  final email = stringField(body, 'email');
  if (name == null) return validationError('name is required');
  if (email == null || !email.contains('@')) {
    return validationError('A valid email is required');
  }
  final taken = db.select(
    'SELECT 1 FROM users WHERE email = ? AND id != ?',
    [email, userId],
  );
  if (taken.isNotEmpty) return emailTaken();

  _load(userId); // makes sure the profile row exists
  db.execute(
    'UPDATE users SET name = ?, email = ? WHERE id = ?',
    [name, email, userId],
  );
  db.execute(
    'UPDATE profiles SET phone = ?, about = ? WHERE user_id = ?',
    [
      body['phone'] is String ? (body['phone'] as String).trim() : '',
      body['about'] is String ? (body['about'] as String).trim() : '',
      userId,
    ],
  );
  return jsonResponse(_load(userId));
}
