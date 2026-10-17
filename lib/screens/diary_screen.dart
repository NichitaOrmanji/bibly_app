import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../utils/app_constants.dart';
import '../widgets/diary_entry_card.dart';
import '../widgets/section_header.dart';
import 'tabernacle_lock_screen.dart';

/// «Дневник» — обычные записи и вход в «Скинию» (приватные записи).
class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const entries = MockData.diaryEntries;

    return Scaffold(
      appBar: AppBar(title: const Text('Дневник')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.history_edu),
        label: const Text('Новая запись'),
      ),
      body: ListView(
        // Нижний отступ, чтобы FAB не закрывал последнюю запись.
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          Card(
            elevation: 0,
            color: scheme.secondaryContainer,
            margin: const EdgeInsets.fromLTRB(
              AppConstants.paddingMedium,
              AppConstants.paddingSmall,
              AppConstants.paddingMedium,
              0,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              leading: CircleAvatar(
                backgroundColor: scheme.secondary,
                child: Icon(Icons.lock, color: scheme.onSecondary),
              ),
              title: Text(
                'Скиния',
                style: TextStyle(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Личные записи · ${MockData.tabernacleEntries.length} · '
                'вход по паролю',
                style: TextStyle(color: scheme.onSecondaryContainer),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: scheme.onSecondaryContainer,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TabernacleLockScreen()),
              ),
            ),
          ),
          SectionHeader(title: 'Мои записи', trailing: '${entries.length}'),
          for (final entry in entries) DiaryEntryCard(entry: entry),
        ],
      ),
    );
  }
}
