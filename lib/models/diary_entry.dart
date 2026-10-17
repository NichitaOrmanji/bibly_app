/// Запись дневника. Обычные записи видны в «Дневнике»,
/// приватные ([isPrivate]) — только в «Скинии» после ввода пароля.
class DiaryEntry {
  final String title;
  final String text;
  final String dateLabel;

  /// Стих, к которому относится запись (необязательно).
  final String? verseReference;

  final bool isPrivate;

  const DiaryEntry({
    required this.title,
    required this.text,
    required this.dateLabel,
    this.verseReference,
    this.isPrivate = false,
  });
}
