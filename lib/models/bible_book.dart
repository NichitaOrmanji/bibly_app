/// Завет, к которому относится книга.
enum Testament { old, newTestament }

/// Книга Библии: номер, полное и краткое название, число глав, завет.
class BibleBook {
  /// Номер книги в синодальном порядке (1 — Бытие, 43 — От Иоанна).
  /// Путешествует в адресе: /bible/43.
  final int id;
  final String name;
  final String abbreviation;
  final int chapters;
  final Testament testament;

  const BibleBook(
    this.id,
    this.name,
    this.abbreviation,
    this.chapters,
    this.testament,
  );

  /// Из JSON сервера (ЛР5). Завет приходит строкой: 'old' или 'new'.
  factory BibleBook.fromJson(Map<String, dynamic> j) => BibleBook(
    j['id'] as int,
    j['name'] as String,
    j['abbreviation'] as String,
    j['chapters'] as int,
    switch (j['testament'] as String) {
      'old' => Testament.old,
      'new' => Testament.newTestament,
      final t => throw FormatException('Неизвестный завет: $t'),
    },
  );
}
