import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/community_model.dart';
import '../utils/app_constants.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_view.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/section_header.dart';

/// Выход из группы: подтверждение → SnackBar → назад.
Future<void> _leave(BuildContext context, String name) async {
  final ok = await showConfirmDialog(
    context,
    title: 'Покинуть группу?',
    message: 'Вы перестанете видеть прогресс и записи группы «$name».',
    confirmLabel: 'Покинуть',
  );
  if (ok && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Вы покинули группу «$name»')));
    context.pop();
  }
}

/// Группа — адрес /together/:groupId. План, прогресс и участники.
class GroupScreen extends StatelessWidget {
  final int groupId;

  const GroupScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final model = context.watch<CommunityModel>();
    final group = model.byId(groupId);
    if (group == null) {
      // Грузится / упало / загружено, но такой группы нет (вышли из неё).
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: model.isLoading
              ? const CircularProgressIndicator()
              : model.error != null
              ? ErrorView(
                  message: model.error!,
                  onRetry: () => context.read<CommunityModel>().load(),
                )
              : const Text('Группа не существует'),
        ),
      );
    }
    final members = group.memberNames;

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
                        onPressed: () => _leave(context, group.name),
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
