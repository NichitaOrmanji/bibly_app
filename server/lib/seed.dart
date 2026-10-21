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
  _seedCommunity();
}

void _seedCommunity() {
  const groups = [
    (1, 'Малая группа «Филиппийцы»', 8, 'Послание к Филиппийцам', 0.75),
    (2, 'Студенты УТМ', 23, 'Евангелие от Иоанна за 21 день', 0.43),
    (3, 'Семья Орманжи', 4, 'Псалмы утешения', 0.6),
    (4, 'Утренний кофе и Притчи', 12, 'Притчи — глава в день', 0.32),
    (5, 'Молодёжь церкви «Благодать»', 31, 'Нагорная проповедь', 0.9),
    (6, 'Библия за год 2026', 146, 'Вся Библия за 365 дней', 0.79),
  ];
  // Demo member names: each group lists the first N of them.
  const people = [
    'Никита Орманжи', 'Андрей Чобану', 'Елена Русу', 'Максим Бурлаку',
    'Ольга Попеску', 'Даниил Морарь', 'Мария Лупу', 'Сергей Гуцу',
    'Ирина Ткачук', 'Виктор Йордаке',
  ];
  for (final (id, name, members, plan, progress) in groups) {
    db.execute(
      'INSERT OR IGNORE INTO reading_groups (id, name, members, plan, progress) '
      'VALUES (?, ?, ?, ?, ?)',
      [id, name, members, plan, progress],
    );
    for (var i = 0; i < members && i < people.length; i++) {
      db.execute(
        'INSERT OR IGNORE INTO group_members (group_id, position, name) '
        'VALUES (?, ?, ?)',
        [id, i, people[i]],
      );
    }
  }

  const feed = [
    (1, 'Андрей Чобану', 'закончил план «Нагорная проповедь»', '15 мин назад',
        null, 6),
    (2, 'Елена Русу', 'поделилась записью к Флп 4:6', '1 ч назад',
        'Перестала тревожиться о сессии, когда начала записывать молитвы. '
            'Список длинный, но на душе тише.', 11),
    (3, 'Максим Бурлаку', 'читает Ин 3 — день 12 из 21', '2 ч назад', null, 2),
    (4, 'Ольга Попеску', 'просит молитвы', '3 ч назад',
        'Завтра у папы операция. Буду благодарна за молитвы обо всей нашей '
            'семье.', 24),
    (5, 'Даниил Морарь', '30 дней подряд с Библией', 'вчера', null, 9),
    (6, 'Мария Лупу', 'поделилась записью к Пс 22:1', 'вчера',
        'Господь — Пастырь мой. Перечитала в автобусе и впервые не спешила.',
        7),
    (7, 'Сергей Гуцу', 'присоединился к группе «Студенты УТМ»', '2 дня назад',
        null, 3),
  ];
  for (final (id, name, action, time, shared, prayers) in feed) {
    db.execute(
      'INSERT OR IGNORE INTO feed '
      '(id, name, action, time_label, shared_text, prayers) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      [id, name, action, time, shared, prayers],
    );
  }
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
