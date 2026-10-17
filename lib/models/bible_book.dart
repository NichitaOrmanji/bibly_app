/// Завет, к которому относится книга.
enum Testament { old, newTestament }

/// Книга Библии: полное и краткое название, число глав, завет.
class BibleBook {
  final String name;
  final String abbreviation;
  final int chapters;
  final Testament testament;

  const BibleBook(this.name, this.abbreviation, this.chapters, this.testament);
}
