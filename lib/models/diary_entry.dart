/// Запись дневника. Обычные записи видны в «Дневнике»,
/// приватные ([isPrivate]) — только в «Скинии» после ввода пароля.
class DiaryEntry {
  /// Уникальный номер записи — путешествует в адресе: /diary/5.
  /// У нового черновика id = 0: настоящий даёт хранилище (на L5 — сервер).
  final int id;
  final String title;
  final String text;
  final String dateLabel;

  /// Стих, к которому относится запись (необязательно).
  final String? verseReference;

  final bool isPrivate;

  const DiaryEntry({
    required this.id,
    required this.title,
    required this.text,
    required this.dateLabel,
    this.verseReference,
    this.isPrivate = false,
  });

  /// «Та же запись, другая идентичность» (create) или другие поля (update).
  DiaryEntry copyWith({
    int? id,
    String? title,
    String? text,
    String? dateLabel,
    String? verseReference,
    bool? isPrivate,
  }) => DiaryEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    text: text ?? this.text,
    dateLabel: dateLabel ?? this.dateLabel,
    verseReference: verseReference ?? this.verseReference,
    isPrivate: isPrivate ?? this.isPrivate,
  );
}
