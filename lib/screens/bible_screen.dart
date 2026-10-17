import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/bible_book.dart';
import '../utils/app_constants.dart';
import '../widgets/book_tile.dart';
import '../widgets/section_header.dart';
import 'chapter_screen.dart';

/// «Библия» — продолжить чтение и список всех книг,
/// разделённый на Ветхий и Новый Завет.
class BibleScreen extends StatelessWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final oldBooks =
        MockData.books.where((b) => b.testament == Testament.old).toList();
    final newBooks = MockData.books
        .where((b) => b.testament == Testament.newTestament)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Библия'),
        actions: [
          IconButton(
            tooltip: 'Поиск',
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
        children: [
          Card(
            elevation: 0,
            color: scheme.primaryContainer,
            margin: const EdgeInsets.fromLTRB(
              AppConstants.paddingMedium,
              AppConstants.paddingSmall,
              AppConstants.paddingMedium,
              0,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              leading: Icon(
                Icons.bookmark,
                color: scheme.onPrimaryContainer,
              ),
              title: Text(
                'Продолжить: ${MockData.lastReadBook}, '
                'глава ${MockData.lastReadChapter}',
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                MockData.translation,
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
              trailing: Icon(
                Icons.arrow_forward,
                color: scheme.onPrimaryContainer,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChapterScreen()),
              ),
            ),
          ),
          SectionHeader(
            title: 'Ветхий Завет',
            trailing: '${oldBooks.length} книг',
          ),
          for (final book in oldBooks) BookTile(book: book, onTap: () {}),
          SectionHeader(
            title: 'Новый Завет',
            trailing: '${newBooks.length} книг',
          ),
          for (final book in newBooks) BookTile(book: book, onTap: () {}),
        ],
      ),
    );
  }
}
