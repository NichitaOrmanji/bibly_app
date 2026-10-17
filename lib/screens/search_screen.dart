import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../utils/app_constants.dart';
import '../widgets/verse_card.dart';

/// «Поиск» — поле поиска, фильтры, недавние запросы и результаты.
/// Всё статично: показан готовый результат по запросу «любовь»,
/// реальный поиск и фильтрация появятся в ЛР4.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const List<String> _filters = [
    'Все',
    'Ветхий Завет',
    'Новый Завет',
    'Мой дневник',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const results = MockData.searchResults;

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
            // TextFormField здесь только ради initialValue — без Form
            // и без validator, как требует ЛР2.
            child: TextFormField(
              initialValue: MockData.searchQuery,
              decoration: const InputDecoration(
                hintText: 'Слово, место или запись',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.close),
              ),
            ),
          ),
          // Фильтры — горизонтальная лента чипов, выбран первый.
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
                selected: i == 0,
                onSelected: (_) {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Wrap(
              spacing: AppConstants.paddingSmall,
              runSpacing: AppConstants.paddingSmall / 2,
              children: [
                for (final q in MockData.recentSearches)
                  ActionChip(
                    avatar: Icon(Icons.history, size: 18, color: scheme.outline),
                    label: Text(q),
                    onPressed: () {},
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMedium,
              AppConstants.paddingMedium,
              AppConstants.paddingMedium,
              AppConstants.paddingSmall,
            ),
            child: Text(
              'Найдено стихов: ${results.length}',
              style: textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
              itemCount: results.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppConstants.paddingSmall),
              itemBuilder: (context, i) => VerseCard(verse: results[i]),
            ),
          ),
        ],
      ),
    );
  }
}
