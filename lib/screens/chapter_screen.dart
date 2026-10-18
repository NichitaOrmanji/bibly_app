import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/bible_book.dart';
import '../models/bible_model.dart';
import '../models/chapter_text.dart';
import '../models/profile_model.dart';
import '../utils/app_constants.dart';
import '../widgets/error_view.dart';
import '../widgets/verse_line.dart';

/// «Чтение главы» — адрес /bible/:bookId/:chapter.
/// Номера приходят из адреса; книга и текст главы — из [BibleModel].
class ChapterScreen extends StatefulWidget {
  final int bookId;
  final int chapter;

  const ChapterScreen({super.key, required this.bookId, required this.chapter});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  @override
  void initState() {
    super.initState();
    // Глава грузится при открытии экрана. После первого кадра — чтобы
    // notifyListeners модели не пришёлся на построение дерева.
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() =>
      context.read<BibleModel>().loadChapter(widget.bookId, widget.chapter);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final model = context.watch<BibleModel>();
    final book = model.byId(widget.bookId);
    final translation = context.watch<ProfileModel>().profile?.translation;

    if (book == null) {
      // У null два смысла: книги ещё грузятся / загружены, но id нет.
      return Scaffold(
        appBar: AppBar(),
        body: model.isLoading
            ? const Center(child: CircularProgressIndicator())
            : model.error != null
            ? ErrorView(
                message: model.error!,
                onRetry: () => context.read<BibleModel>().load(),
              )
            : const Center(child: Text('Книга не существует')),
      );
    }

    final text = model.chapter(widget.bookId, widget.chapter);
    final error = model.chapterError(widget.bookId, widget.chapter);

    final Widget body;
    if (error != null) {
      body = ErrorView(message: error, onRetry: _load); // 2) упало
    } else if (text == null) {
      // 1) грузится (или запрос вот-вот уйдёт после первого кадра)
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = _ChapterBody(book: book, text: text); // 3) данные
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('${book.name} ${widget.chapter}'),
            if (translation != null)
              Text(
                '$translation перевод',
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
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Закладка: ${book.name} ${widget.chapter}'),
              ),
            ),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: _ChapterNavigation(
        book: book,
        chapter: widget.chapter,
      ),
    );
  }
}

/// Текст главы или пояснение, что текста в источнике пока нет.
class _ChapterBody extends StatelessWidget {
  final BibleBook book;
  final ChapterText text;

  const _ChapterBody({required this.book, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!text.hasText) {
      return Center(
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
                '${book.name}, глава ${text.chapter}',
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
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMedium,
        AppConstants.paddingSmall,
        AppConstants.paddingMedium,
        AppConstants.paddingLarge,
      ),
      children: [
        if (text.heading != null)
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            child: Text(
              text.heading!,
              style: textTheme.titleLarge?.copyWith(color: scheme.primary),
            ),
          ),
        for (final verse in text.verses) VerseLine(verse: verse),
      ],
    );
  }
}

/// Нижняя панель: соседние главы и «В дневник».
class _ChapterNavigation extends StatelessWidget {
  final BibleBook book;
  final int chapter;

  const _ChapterNavigation({required this.book, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingSmall),
        child: Row(
          children: [
            TextButton.icon(
              // pushReplacement: соседняя глава заменяет текущую,
              // и «назад» по-прежнему ведёт к списку глав.
              onPressed: chapter > 1
                  ? () => context.pushReplacement(
                      '/bible/${book.id}/${chapter - 1}',
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
                      '/bible/${book.id}/${chapter + 1}',
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
    );
  }
}
