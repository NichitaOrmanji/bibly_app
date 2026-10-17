import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/daily_task.dart';
import '../utils/app_constants.dart';
import '../widgets/daily_task_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/verse_card.dart';
import 'chapter_screen.dart';

/// «Мой день» — главный экран: приветствие, серия дней, стих дня
/// и план на сегодня. Все данные из [MockData].
class MyDayScreen extends StatelessWidget {
  const MyDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const plan = MockData.todayPlan;
    final doneCount = plan.where((t) => t.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой день'),
        actions: [
          IconButton(
            tooltip: 'Поиск',
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMedium,
              AppConstants.paddingSmall,
              AppConstants.paddingMedium,
              AppConstants.paddingMedium,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Доброе утро, ${MockData.userName}!',
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        MockData.todayLabel,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    Icons.local_fire_department,
                    color: scheme.tertiary,
                  ),
                  label: Text('${MockData.streakDays} дней'),
                ),
              ],
            ),
          ),
          const VerseCard(verse: MockData.verseOfDay, label: 'Стих дня'),
          SectionHeader(
            title: 'План на сегодня',
            trailing: '$doneCount из ${plan.length}',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: LinearProgressIndicator(
              value: doneCount / plan.length,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          for (final task in plan)
            DailyTaskTile(
              task: task,
              // Пока открывается только отрывок из Библии.
              onTap: task.type == DailyTaskType.reading
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChapterScreen(),
                        ),
                      )
                  : null,
            ),
        ],
      ),
    );
  }
}
