import 'package:flutter/material.dart';

import '../models/verse.dart';
import '../utils/app_constants.dart';

/// Карточка со стихом: подпись сверху, текст стиха и ссылка на место.
/// Используется для «Стиха дня» и в результатах поиска.
class VerseCard extends StatelessWidget {
  final Verse verse;
  final String? label;

  const VerseCard({super.key, required this.verse, this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: scheme.primaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Text(
                    label!,
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
            ],
            Text(
              '«${verse.text}»',
              style: textTheme.titleMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                verse.reference,
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
