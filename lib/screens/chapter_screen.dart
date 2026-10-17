import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../utils/app_constants.dart';
import '../widgets/verse_line.dart';

/// «Чтение главы» — текст главы по стихам, выделенные стихи,
/// переход к предыдущей и следующей главе (кнопки пока статические).
class ChapterScreen extends StatelessWidget {
  const ChapterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('${MockData.lastReadBook} ${MockData.lastReadChapter}'),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingMedium,
          AppConstants.paddingSmall,
          AppConstants.paddingMedium,
          AppConstants.paddingLarge,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingSmall,
              vertical: AppConstants.paddingSmall,
            ),
            child: Text(
              MockData.chapterHeading,
              style: textTheme.titleLarge?.copyWith(color: scheme.primary),
            ),
          ),
          for (final verse in MockData.chapterVerses) VerseLine(verse: verse),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left),
                label: const Text('Глава 2'),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.history_edu),
                label: const Text('В дневник'),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Глава 4'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
