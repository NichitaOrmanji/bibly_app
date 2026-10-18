import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../utils/app_constants.dart';

/// Запись дневника — адреса /diary/:id и /diary/tabernacle/:id.
/// Экран получает id из адреса и сам ищет запись (сначала в Дневнике,
/// затем в Скинии); объект через extra не передаётся.
class EntryScreen extends StatelessWidget {
  final int id;

  const EntryScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final entry = [
      ...MockData.diaryEntries,
      ...MockData.tabernacleEntries,
    ].firstWhere((e) => e.id == id);

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.isPrivate ? 'Скиния' : 'Запись'),
        actions: [
          IconButton(
            tooltip: 'Удалить',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          Row(
            children: [
              Icon(
                entry.isPrivate ? Icons.lock : Icons.public,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                '${entry.dateLabel} · '
                '${entry.isPrivate ? 'видна только вам' : 'видна группе'}',
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(entry.title, style: textTheme.headlineSmall),
          if (entry.verseReference != null) ...[
            const SizedBox(height: AppConstants.paddingSmall),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: Icon(Icons.menu_book, color: scheme.primary),
                label: Text(entry.verseReference!),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.paddingMedium),
          Text(entry.text, style: textTheme.bodyLarge?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}
