/// Стих Писания: текст и ссылка на место («Ин 3:16»).
class Verse {
  final String text;
  final String reference;

  const Verse({required this.text, required this.reference});

  factory Verse.fromJson(Map<String, dynamic> j) =>
      Verse(text: j['text'] as String, reference: j['reference'] as String);
}
