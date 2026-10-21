// Bibly reference data, shared by all users: today's plan, Bible books
// and verses, reading groups, the friends' feed. Inserted on every start
// with INSERT OR IGNORE and fixed ids, so restarts never duplicate rows.
//
// User data (diary entries, "done" marks, profile) is NOT seeded here:
// it is created through the API.

import 'db.dart';

/// Fills the reference tables. Called once from bin/server.dart after initDb.
void seedReferenceData() {
  _seedDayPlan();
}

void _seedDayPlan() {
  db.execute(
    'INSERT OR IGNORE INTO day_plan (id, date_label, verse_text, verse_ref) '
    'VALUES (1, ?, ?, ?)',
    [
      'Суббота, 17 октября',
      'Ибо так возлюбил Бог мир, что отдал Сына Своего Единородного, '
          'дабы всякий верующий в Него не погиб, но имел жизнь вечную.',
      'Ин 3:16',
    ],
  );
  // Always 4 steps in one order: quote -> reading -> reflection -> prayer.
  const tasks = [
    (1, 'Цитата дня',
        '«Молитва не меняет Бога, но меняет молящегося» — С. Кьеркегор', 1,
        'quote'),
    (2, 'Отрывок из Библии', 'Ин 3:1–21 · Беседа Иисуса с Никодимом', 7,
        'reading'),
    (3, 'Размышление', 'Что значит «родиться свыше»?', 5, 'reflection'),
    (4, 'Призыв к молитве', 'Помолитесь о тех, кто ищет ответы, как Никодим',
        3, 'prayer'),
  ];
  for (final (id, title, subtitle, minutes, type) in tasks) {
    db.execute(
      'INSERT OR IGNORE INTO daily_tasks '
      '(id, position, title, subtitle, minutes, type) VALUES (?, ?, ?, ?, ?, ?)',
      [id, id, title, subtitle, minutes, type],
    );
  }
}
