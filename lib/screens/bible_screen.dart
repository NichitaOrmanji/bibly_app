import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../models/bible_book.dart';
import '../utils/app_constants.dart';
import '../widgets/book_tile.dart';
import '../widgets/section_header.dart';

/// «Библия» — продолжить чтение и список всех книг,
/// разделённый на Ветхий и Новый Завет.
class BibleScreen extends StatelessWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const books = MockData.books;
    final oldCount = books.where((b) => b.testament == Testament.old).length;
    final newCount = books.length - oldCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Библия'),
        actions: [
          IconButton(
            tooltip: 'Поиск',
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      // ListView.builder строит строки лениво — только видимые из 66 книг.
      // Элемент 0 — карточка «Продолжить», дальше — книги.
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
        itemCount: books.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) return const _ContinueReadingCard();

          final book = books[i - 1];
          final tile = BookTile(book: book, onTap: () {});

          // Заголовок завета ставим перед первой книгой каждого завета.
          final startsTestament =
              i == 1 || books[i - 2].testament != book.testament;
          if (!startsTestament) return tile;

          final isOld = book.testament == Testament.old;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: isOld ? 'Ветхий Завет' : 'Новый Завет',
                trailing: '${isOld ? oldCount : newCount} книг',
              ),
              tile,
            ],
          );
        },
      ),
    );
  }
}

/// Карточка «Продолжить чтение» — открывает главу, где остановился читатель.
class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
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
        leading: Icon(Icons.bookmark, color: scheme.onPrimaryContainer),
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
        trailing: Icon(Icons.arrow_forward, color: scheme.onPrimaryContainer),
        onTap: () => context.push(
          '/bible/${MockData.lastReadBookId}/${MockData.lastReadChapter}',
        ),
      ),
    );
  }
}
