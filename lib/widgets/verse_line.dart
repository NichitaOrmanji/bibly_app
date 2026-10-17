import 'package:flutter/material.dart';

import '../models/chapter_verse.dart';
import '../utils/app_constants.dart';

/// Один стих при чтении главы: маленький номер и текст.
/// Выделенный стих подсвечивается фоном.
class VerseLine extends StatelessWidget {
  final ChapterVerse verse;

  const VerseLine({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: 4,
      ),
      decoration: verse.isHighlighted
          ? BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppConstants.paddingSmall),
            )
          : null,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${verse.number} ',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: verse.text),
          ],
        ),
        style: textTheme.bodyLarge?.copyWith(
          height: 1.6,
          color: verse.isHighlighted ? scheme.onTertiaryContainer : null,
        ),
      ),
    );
  }
}
