import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../utils/app_constants.dart';
import '../widgets/diary_entry_card.dart';

/// «Скиния» — приватные записи, открываются после ввода пароля.
class TabernacleScreen extends StatelessWidget {
  const TabernacleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const entries = MockData.tabernacleEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Скиния'),
        actions: [
          IconButton(
            tooltip: 'Закрыть Скинию',
            icon: const Icon(Icons.lock),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.history_edu),
        label: const Text('Личная запись'),
      ),
      // Элемент 0 — подсказка о приватности, дальше — записи.
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: entries.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                children: [
                  Icon(Icons.visibility_off, size: 18, color: scheme.secondary),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      'Эти записи видны только вам',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            );
          }
          return DiaryEntryCard(entry: entries[i - 1]);
        },
      ),
    );
  }
}
