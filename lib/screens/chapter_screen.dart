import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../utils/app_constants.dart';
import '../widgets/verse_line.dart';

/// «Чтение главы» — адрес /bible/:bookId/:chapter.
/// Экран получает номера из адреса и сам находит книгу в данных.
class ChapterScreen extends StatelessWidget {
  final int bookId;
  final int chapter;

  const ChapterScreen({super.key, required this.bookId, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Поиск по id — сегодня в mock-данных, на L5 — с сервера.
    final book = MockData.books.firstWhere((b) => b.id == bookId);
    // Текст в mock-данных есть только у Ин 3; остальные главы — заглушка.
    final hasText =
        bookId == MockData.lastReadBookId &&
        chapter == MockData.lastReadChapter;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('${book.name} $chapter'),
            Text(
              MockData.translation,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Размер текста',
            icon: const Icon(Icons.text_fields),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Закладка',
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: hasText
          ? ListView(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingMedium,
                AppConstants.paddingSmall,
                AppConstants.paddingMedium,
                AppConstants.paddingLarge,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  child: Text(
                    MockData.chapterHeading,
                    style: textTheme.titleLarge?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
                for (final verse in MockData.chapterVerses)
                  VerseLine(verse: verse),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_download_outlined,
                      size: 56,
                      color: scheme.outline,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      '${book.name}, глава $chapter',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Текст этой главы будет загружаться с сервера '
                      '(ЛР5). Пример текста — От Иоанна, глава 3.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Row(
            children: [
              TextButton.icon(
                // pushReplacement: соседняя глава заменяет текущую,
                // и «назад» по-прежнему ведёт к списку глав.
                onPressed: chapter > 1
                    ? () => context.pushReplacement(
                        '/bible/$bookId/${chapter - 1}',
                      )
                    : null,
                icon: const Icon(Icons.chevron_left),
                label: Text('Гл. ${chapter > 1 ? chapter - 1 : chapter}'),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                // go: переход в другой раздел (вкладку «Дневник»);
                // ссылка на главу передаётся query-параметром.
                onPressed: () => context.go(
                  Uri(
                    path: '/diary/new',
                    queryParameters: {'verse': '${book.abbreviation} $chapter'},
                  ).toString(),
                ),
                icon: const Icon(Icons.history_edu),
                label: const Text('В дневник'),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: chapter < book.chapters
                    ? () => context.pushReplacement(
                        '/bible/$bookId/${chapter + 1}',
                      )
                    : null,
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.chevron_right),
                label: Text(
                  'Гл. ${chapter < book.chapters ? chapter + 1 : chapter}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
