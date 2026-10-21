import 'chapter_verse.dart';

/// Текст главы, как его отдаёт хранилище. Пустой [verses] — текста
/// главы в источнике пока нет (полная Библия — с сервера в ЛР5).
class ChapterText {
  final int bookId;
  final int chapter;
  final String? heading;
  final List<ChapterVerse> verses;

  const ChapterText({
    required this.bookId,
    required this.chapter,
    this.heading,
    this.verses = const [],
  });

  /// Из JSON сервера (ЛР5): GET /books/{id}/chapters/{n}.
  factory ChapterText.fromJson(Map<String, dynamic> j) => ChapterText(
    bookId: j['bookId'] as int,
    chapter: j['chapter'] as int,
    heading: j['heading'] as String?,
    verses: [
      for (final v in j['verses'] as List)
        ChapterVerse.fromJson(v as Map<String, dynamic>),
    ],
  );

  bool get hasText => verses.isNotEmpty;
}
