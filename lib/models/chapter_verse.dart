/// Стих внутри главы: номер, текст и признак выделения
/// (выделенные стихи подсвечиваются при чтении).
class ChapterVerse {
  final int number;
  final String text;
  final bool isHighlighted;

  const ChapterVerse(this.number, this.text, {this.isHighlighted = false});

  factory ChapterVerse.fromJson(Map<String, dynamic> j) => ChapterVerse(
    j['number'] as int,
    j['text'] as String,
    isHighlighted: j['isHighlighted'] as bool? ?? false,
  );
}
