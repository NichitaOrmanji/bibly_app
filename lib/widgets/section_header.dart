import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

/// Заголовок раздела экрана с необязательной подписью справа
/// («3 из 7», «Все»). Используется на нескольких экранах.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMedium,
        AppConstants.paddingLarge,
        AppConstants.paddingMedium,
        AppConstants.paddingSmall,
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: textTheme.titleLarge)),
          if (trailing != null)
            Text(
              trailing!,
              style: textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
