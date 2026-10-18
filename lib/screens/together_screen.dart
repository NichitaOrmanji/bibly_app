import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../models/community.dart';
import '../utils/app_constants.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/section_header.dart';

/// «Вместе» — группы совместного чтения (горизонтальный список)
/// и лента друзей: прогресс, записи, которыми поделились, просьбы о молитве.
class TogetherScreen extends StatelessWidget {
  const TogetherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const groups = MockData.groups;
    const feed = MockData.feed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вместе'),
        actions: [
          IconButton(
            tooltip: 'Пригласить друга',
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
        children: [
          SectionHeader(title: 'Мои группы', trailing: '${groups.length}'),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              itemCount: groups.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppConstants.paddingSmall),
              itemBuilder: (context, i) => _GroupCard(
                group: groups[i],
                onTap: () => context.push('/together/${groups[i].id}'),
              ),
            ),
          ),
          const SectionHeader(title: 'Лента друзей'),
          for (final item in feed) _ActivityCard(activity: item),
        ],
      ),
    );
  }
}

/// Карточка группы в горизонтальном списке.
class _GroupCard extends StatelessWidget {
  final ReadingGroup group;
  final VoidCallback? onTap;

  const _GroupCard({required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 220,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.secondaryContainer,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  group.plan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
                const Spacer(),
                LinearProgressIndicator(
                  value: group.progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Row(
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 16,
                      color: scheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.members}',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(group.progress * 100).round()}%',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Событие ленты: аватар, имя, действие, время, текст записи
/// и кнопка «Помолюсь» со счётчиком.
class _ActivityCard extends StatelessWidget {
  final FriendActivity activity;

  const _ActivityCard({required this.activity});

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
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(name: activity.name),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.name, style: textTheme.titleSmall),
                      Text(
                        activity.action,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (activity.sharedText != null) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Text(activity.sharedText!, style: textTheme.bodyMedium),
            ],
            const SizedBox(height: AppConstants.paddingSmall),
            Row(
              children: [
                // Expanded отдаёт времени только оставшееся место,
                // поэтому на узком экране строка не переполняется.
                Expanded(
                  child: Text(
                    activity.timeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Вы помолитесь: ${activity.name.split(' ').first} '
                        'получит уведомление',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.volunteer_activism_outlined, size: 18),
                  label: Text('Помолюсь · ${activity.prayers}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
