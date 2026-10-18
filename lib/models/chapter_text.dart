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

  bool get hasText => verses.isNotEmpty;
}
