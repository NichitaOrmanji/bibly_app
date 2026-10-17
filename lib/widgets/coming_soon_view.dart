import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

/// Временная заглушка для вкладок, экраны которых ещё не сделаны.
class ComingSoonView extends StatelessWidget {
  final String title;
  final IconData icon;

  const ComingSoonView({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: scheme.outline),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Раздел «$title» скоро появится',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
