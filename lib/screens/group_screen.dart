import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../utils/app_constants.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/section_header.dart';

/// Группа — адрес /together/:groupId. План, прогресс и участники.
class GroupScreen extends StatelessWidget {
  final int groupId;

  const GroupScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final group = MockData.groups.firstWhere((g) => g.id == groupId);
    // Участников в mock-данных общий список — показываем первых N.
    final members = MockData.groupMembers.take(group.members).toList();

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
        itemCount: members.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Текущий план', style: textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(group.plan, style: textTheme.titleLarge),
                      const SizedBox(height: AppConstants.paddingMedium),
                      LinearProgressIndicator(
                        value: group.progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Пройдено ${(group.progress * 100).round()}% · '
                        'участников: ${group.members}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.error,
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Покинуть группу'),
                      ),
                    ],
                  ),
                ),
                const SectionHeader(title: 'Участники'),
              ],
            );
          }
          final name = members[i - 1];
          return ListTile(
            leading: InitialsAvatar(name: name),
            title: Text(name),
          );
        },
      ),
    );
  }
}
