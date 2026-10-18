import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../models/bible_book.dart';
import '../utils/app_constants.dart';
import '../widgets/book_tile.dart';

/// Книга — адрес /bible/:bookId. Сетка номеров глав;
/// нажатие открывает главу: push на /bible/:bookId/:chapter.
class BookScreen extends StatelessWidget {
  final int bookId;

  const BookScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Экран сам находит книгу по id из адреса.
    final book = MockData.books.firstWhere((b) => b.id == bookId);

    return Scaffold(
      appBar: AppBar(title: Text(book.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMedium,
              AppConstants.paddingSmall,
              AppConstants.paddingMedium,
              AppConstants.paddingMedium,
            ),
            child: Text(
              '${book.testament == Testament.old ? 'Ветхий' : 'Новый'} Завет · '
              '${BookTile.chaptersLabel(book.chapters)} · '
              'книга ${book.id} из ${MockData.books.length}',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingMedium,
                0,
                AppConstants.paddingMedium,
                AppConstants.paddingLarge,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 72,
                mainAxisSpacing: AppConstants.paddingSmall,
                crossAxisSpacing: AppConstants.paddingSmall,
              ),
              itemCount: book.chapters,
              itemBuilder: (context, i) {
                final chapter = i + 1;
                final isLastRead =
                    book.id == MockData.lastReadBookId &&
                    chapter == MockData.lastReadChapter;
                return Material(
                  color: isLastRead
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    // push: «зайду и вернусь» к списку глав.
                    onTap: () => context.push('/bible/${book.id}/$chapter'),
                    child: Center(
                      child: Text(
                        '$chapter',
                        style: textTheme.titleMedium?.copyWith(
                          color: isLastRead
                              ? scheme.onPrimaryContainer
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
