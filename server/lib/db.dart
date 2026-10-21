// SQLite setup. The database file is created automatically on first start.
//
// To add your own entity: add a CREATE TABLE below, then copy the pattern
// of lib/notes.dart for its routes.

import 'package:sqlite3/sqlite3.dart';

/// The single database connection, opened once at startup by [initDb].
late final Database db;

/// Opens (and creates, on first run) the database and its schema.
void initDb(String path) {
  db = sqlite3.open(path);
  db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      email         TEXT    NOT NULL UNIQUE,
      password_hash TEXT    NOT NULL,
      name          TEXT    NOT NULL,
      created_at    TEXT    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS notes (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      title      TEXT    NOT NULL,
      content    TEXT    NOT NULL DEFAULT '',
      created_at TEXT    NOT NULL
    );

    -- Bibly: diary entries. is_private = 1 -> shown only in "Скиния".
    -- search_text = lowercased title/text/verse: SQLite LIKE ignores case
    -- only for ASCII, so Cyrillic search goes through this column.
    CREATE TABLE IF NOT EXISTS entries (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id         INTEGER NOT NULL REFERENCES users (id),
      title           TEXT    NOT NULL,
      text            TEXT    NOT NULL DEFAULT '',
      date_label      TEXT    NOT NULL DEFAULT '',
      verse_reference TEXT,
      is_private      INTEGER NOT NULL DEFAULT 0,
      search_text     TEXT    NOT NULL DEFAULT '',
      created_at      TEXT    NOT NULL
    );

    -- Bibly: "Мой день". One shared plan for today (seeded by seed.dart),
    -- its tasks, and per-user "done" marks.
    CREATE TABLE IF NOT EXISTS day_plan (
      id          INTEGER PRIMARY KEY,
      date_label  TEXT NOT NULL,
      verse_text  TEXT NOT NULL,
      verse_ref   TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS daily_tasks (
      id        INTEGER PRIMARY KEY,
      position  INTEGER NOT NULL,
      title     TEXT    NOT NULL,
      subtitle  TEXT    NOT NULL,
      minutes   INTEGER NOT NULL,
      type      TEXT    NOT NULL  -- quote | reading | reflection | prayer
    );

    CREATE TABLE IF NOT EXISTS task_done (
      user_id INTEGER NOT NULL REFERENCES users (id),
      task_id INTEGER NOT NULL REFERENCES daily_tasks (id),
      PRIMARY KEY (user_id, task_id)
    );

    CREATE TABLE IF NOT EXISTS files (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      name       TEXT    NOT NULL,
      mime_type  TEXT    NOT NULL,
      size       INTEGER NOT NULL,
      path       TEXT    NOT NULL,
      created_at TEXT    NOT NULL
    );
  ''');
}

/// Current UTC time in ISO-8601, the format used for all timestamps.
String nowIso() => DateTime.now().toUtc().toIso8601String();
