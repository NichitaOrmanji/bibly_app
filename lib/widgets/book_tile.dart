import 'package:flutter/material.dart';

import '../models/bible_book.dart';

/// Строка списка книг: краткое название в кружке, полное название
/// и число глав. Используется в списке книг и в поиске.
class BookTile extends StatelessWidget {
  final BibleBook book;
  final VoidCallback? onTap;

  const BookTile({super.key, required this.book, this.onTap});

  /// «1 глава», «3 главы», «50 глав» — русское склонение по числу.
  static String chaptersLabel(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return '$n глава';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return '$n главы';
    }
    return '$n глав';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: book.testament == Testament.old
            ? scheme.tertiaryContainer
            : scheme.secondaryContainer,
        child: Text(
          book.abbreviation,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: book.testament == Testament.old
                ? scheme.onTertiaryContainer
                : scheme.onSecondaryContainer,
          ),
        ),
      ),
      title: Text(book.name),
      subtitle: Text(chaptersLabel(book.chapters)),
      trailing: Icon(Icons.chevron_right, color: scheme.outline),
      onTap: onTap,
    );
  }
}
