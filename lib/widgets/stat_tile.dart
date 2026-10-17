import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

/// Плитка статистики «число + подпись» («12 / дней подряд»).
/// В «Профиле» стоит три раза подряд.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium,
          horizontal: AppConstants.paddingSmall,
        ),
        child: Column(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 4),
            Text(value, style: textTheme.titleLarge),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
