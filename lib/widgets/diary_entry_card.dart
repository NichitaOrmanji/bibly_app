import 'package:flutter/material.dart';

import '../models/diary_entry.dart';
import '../utils/app_constants.dart';

/// Карточка записи: дата, заголовок, начало текста и ссылка на стих.
/// Одна и та же карточка используется в «Дневнике» и в «Скинии».
class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;

  const DiaryEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall / 2,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(entry.title, style: textTheme.titleMedium),
                  ),
                  Text(
                    entry.dateLabel,
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                entry.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (entry.verseReference != null) ...[
                const SizedBox(height: AppConstants.paddingSmall),
                Row(
                  children: [
                    Icon(Icons.menu_book, size: 16, color: scheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      entry.verseReference!,
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
