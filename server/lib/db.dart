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

    -- Bibly: "Вместе". Shared reading groups and the friends' feed (seeded).
    -- Every user starts as a member of every group; leaving a group adds a
    -- row to group_leaves, so the group disappears from that user's list.
    CREATE TABLE IF NOT EXISTS reading_groups (
      id       INTEGER PRIMARY KEY,
      name     TEXT    NOT NULL,
      members  INTEGER NOT NULL,
      plan     TEXT    NOT NULL,
      progress REAL    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS group_members (
      group_id INTEGER NOT NULL REFERENCES reading_groups (id),
      position INTEGER NOT NULL,
      name     TEXT    NOT NULL,
      PRIMARY KEY (group_id, position)
    );

    CREATE TABLE IF NOT EXISTS group_leaves (
      user_id  INTEGER NOT NULL REFERENCES users (id),
      group_id INTEGER NOT NULL REFERENCES reading_groups (id),
      PRIMARY KEY (user_id, group_id)
    );

    CREATE TABLE IF NOT EXISTS feed (
      id          INTEGER PRIMARY KEY,
      name        TEXT    NOT NULL,
      action      TEXT    NOT NULL,
      time_label  TEXT    NOT NULL,
      shared_text TEXT,
      prayers     INTEGER NOT NULL DEFAULT 0
    );

    -- Bibly: the Bible (read-only, seeded) and per-user search history.
    CREATE TABLE IF NOT EXISTS books (
      id           INTEGER PRIMARY KEY,  -- synodal order: 1 Genesis .. 66
      name         TEXT    NOT NULL,
      abbreviation TEXT    NOT NULL,
      chapters     INTEGER NOT NULL,
      testament    TEXT    NOT NULL      -- old | new
    );

    CREATE TABLE IF NOT EXISTS chapter_headings (
      book_id INTEGER NOT NULL REFERENCES books (id),
      chapter INTEGER NOT NULL,
      heading TEXT    NOT NULL,
      PRIMARY KEY (book_id, chapter)
    );

    CREATE TABLE IF NOT EXISTS verses (
      book_id     INTEGER NOT NULL REFERENCES books (id),
      chapter     INTEGER NOT NULL,
      number      INTEGER NOT NULL,
      text        TEXT    NOT NULL,
      highlighted INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (book_id, chapter, number)
    );

    CREATE TABLE IF NOT EXISTS searches (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      query      TEXT    NOT NULL,
      created_at TEXT    NOT NULL
    );

    -- Bibly: profile details and settings. name/email stay in users;
    -- a missing row means "all defaults" (see profile.dart).
    CREATE TABLE IF NOT EXISTS profiles (
      user_id          INTEGER PRIMARY KEY REFERENCES users (id),
      phone            TEXT    NOT NULL DEFAULT '',
      about            TEXT    NOT NULL DEFAULT '',
      streak_days      INTEGER NOT NULL DEFAULT 0,
      chapters_read    INTEGER NOT NULL DEFAULT 0,
      last_book_id     INTEGER NOT NULL DEFAULT 43,
      last_chapter     INTEGER NOT NULL DEFAULT 3,
      translation      TEXT    NOT NULL DEFAULT 'Синодальный',
      text_size        TEXT    NOT NULL DEFAULT 'Средний',
      reminder_time    TEXT    NOT NULL DEFAULT 'каждый день в 07:30',
      reminder_on      INTEGER NOT NULL DEFAULT 1,
      share_with_group INTEGER NOT NULL DEFAULT 1,
      language         TEXT    NOT NULL DEFAULT 'Русский'
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
