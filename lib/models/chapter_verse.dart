/// Стих внутри главы: номер, текст и признак выделения
/// (выделенные стихи подсвечиваются при чтении).
class ChapterVerse {
  final int number;
  final String text;
  final bool isHighlighted;

  const ChapterVerse(this.number, this.text, {this.isHighlighted = false});
}
