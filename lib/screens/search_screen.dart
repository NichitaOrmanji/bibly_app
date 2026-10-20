import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/bible_book.dart';
import '../models/bible_model.dart';
import '../models/diary_entry.dart';
import '../models/diary_model.dart';
import '../models/verse.dart';
import '../utils/app_constants.dart';
import '../widgets/diary_entry_card.dart';
import '../widgets/error_view.dart';
import '../widgets/verse_card.dart';

/// «Поиск» — по стихам (через [BibleModel]) и по своим записям
/// (через [DiaryModel]). Запрос и недавние запросы живут в модели —
/// при возврате на экран результаты на месте.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const List<String> _filters = [
    'Все',
    'Ветхий Завет',
    'Новый Завет',
    'Мой дневник',
  ];

  late final TextEditingController _queryCtrl;

  /// Выбранный фильтр — эфемерное состояние экрана: setState, не Provider.
  int _filter = 0;

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: context.read<BibleModel>().query);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) return;
    _queryCtrl.text = query;
    context.read<BibleModel>().search(query); // read: действие
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final model = context.watch<BibleModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Поиск')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMedium,
              AppConstants.paddingSmall,
              AppConstants.paddingMedium,
              0,
            ),
            child: TextField(
              controller: _queryCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Слово, место или запись',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Очистить',
                  icon: const Icon(Icons.close),
                  onPressed: _queryCtrl.clear,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              itemCount: _filters.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppConstants.paddingSmall),
              itemBuilder: (context, i) => FilterChip(
                label: Text(_filters[i]),
                selected: i == _filter,
                onSelected: (_) => setState(() => _filter = i),
              ),
            ),
          ),
          if (model.recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: Wrap(
                spacing: AppConstants.paddingSmall,
                runSpacing: AppConstants.paddingSmall / 2,
                children: [
                  for (final q in model.recentSearches.take(6))
                    ActionChip(
                      avatar: Icon(
                        Icons.history,
                        size: 18,
                        color: scheme.outline,
                      ),
                      label: Text(q),
                      onPressed: () => _search(q),
                    ),
                ],
              ),
            ),
          Expanded(child: _results(context, model)),
        ],
      ),
    );
  }

  /// Три состояния результатов (+ подсказка до первого запроса).
  Widget _results(BuildContext context, BibleModel model) {
    if (model.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.searchError != null) {
      return ErrorView(
        message: model.searchError!,
        onRetry: () => _search(model.query),
      );
    }
    if (model.query.isEmpty) {
      return const Center(child: Text('Введите слово или ссылку на стих'));
    }

    if (_filter == 3) {
      // Записи — данные другой модели, со своей триадой.
      final diary = context.watch<DiaryModel>();
      if (diary.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (diary.error != null) {
        return ErrorView(
          message: diary.error!,
          onRetry: () => context.read<DiaryModel>().load(),
        );
      }
      final entries = _matchingEntries(diary.entries, model.query);
      return _ResultList(
        title: 'Найдено записей: ${entries.length}',
        count: entries.length,
        builder: (context, i) => DiaryEntryCard(
          entry: entries[i],
          // Запись живёт во вкладке «Дневник» — переход в раздел: go.
          onTap: () => context.go(
            entries[i].isPrivate
                ? '/diary/tabernacle/${entries[i].id}'
                : '/diary/${entries[i].id}',
          ),
        ),
      );
    }

    final verses = _filterVerses(model.results, model);
    return _ResultList(
      title: 'Найдено стихов: ${verses.length}',
      count: verses.length,
      builder: (context, i) => VerseCard(verse: verses[i]),
    );
  }

  /// «Ветхий/Новый Завет»: завет книги узнаём по сокращению в ссылке.
  List<Verse> _filterVerses(List<Verse> verses, BibleModel model) {
    if (_filter == 0) return verses;
    final wanted = _filter == 1 ? Testament.old : Testament.newTestament;
    return verses.where((v) {
      final space = v.reference.lastIndexOf(' ');
      final abbr = v.reference
          .substring(0, space)
          .replaceAll(' ', '')
          .toLowerCase();
      final book = model.books.where(
        (b) => b.abbreviation.toLowerCase() == abbr,
      );
      return book.isNotEmpty && book.first.testament == wanted;
    }).toList();
  }

  /// «Мой дневник»: записи, где встречается основа слова запроса.
  List<DiaryEntry> _matchingEntries(List<DiaryEntry> entries, String query) {
    final q = query.toLowerCase();
    final stem = q.length > 3 ? q.substring(0, 3) : q;
    return entries
        .where(
          (e) =>
              e.title.toLowerCase().contains(stem) ||
              e.text.toLowerCase().contains(stem),
        )
        .toList();
  }
}

/// Заголовок «Найдено: N» и список результатов.
class _ResultList extends StatelessWidget {
  final String title;
  final int count;
  final IndexedWidgetBuilder builder;

  const _ResultList({
    required this.title,
    required this.count,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingMedium,
            AppConstants.paddingMedium,
            AppConstants.paddingMedium,
            AppConstants.paddingSmall,
          ),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
            itemCount: count,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppConstants.paddingSmall),
            itemBuilder: builder,
          ),
        ),
      ],
    );
  }
}
