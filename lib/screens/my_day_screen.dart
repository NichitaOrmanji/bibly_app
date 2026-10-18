import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/daily_task.dart';
import '../models/day_plan_model.dart';
import '../models/profile_model.dart';
import '../utils/app_constants.dart';
import '../widgets/daily_task_tile.dart';
import '../widgets/error_view.dart';
import '../widgets/section_header.dart';
import '../widgets/verse_card.dart';

/// «Мой день» — главный экран: приветствие, серия дней, стих дня
/// и план на сегодня. Данные — из [DayPlanModel] и [ProfileModel].
class MyDayScreen extends StatelessWidget {
  const MyDayScreen({super.key});

  Future<void> _toggle(BuildContext context, DailyTask task) async {
    // ДЕЙСТВУЕМ — read в callback-е.
    final error = await context.read<DayPlanModel>().toggle(task.id);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _retry(BuildContext context) {
    context.read<DayPlanModel>().load();
    context.read<ProfileModel>().load();
  }

  @override
  Widget build(BuildContext context) {
    // ПОКАЗЫВАЕМ и следим — watch в build: экран перерисуется
    // при каждом notifyListeners моделей.
    final day = context.watch<DayPlanModel>();
    final profileModel = context.watch<ProfileModel>();
    final error = day.error ?? profileModel.error;

    final Widget body;
    if (day.isLoading || profileModel.isLoading) {
      body = const Center(child: CircularProgressIndicator()); // 1) грузится
    } else if (error != null ||
        profileModel.profile == null ||
        day.verseOfDay == null) {
      body = ErrorView(
        // 2) упало — сообщение и retry
        message: error ?? 'Не удалось загрузить день',
        onRetry: () => _retry(context),
      );
    } else {
      body = _content(context, day, profileModel); // 3) данные
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой день'),
        actions: [
          IconButton(
            tooltip: 'Поиск',
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _content(
    BuildContext context,
    DayPlanModel day,
    ProfileModel profileModel,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final profile = profileModel.profile!;
    final plan = day.tasks;

    return ListView(
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
                      'Доброе утро, ${profile.firstName}!',
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.dateLabel,
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
                label: Text('${profile.streakDays} дней'),
              ),
            ],
          ),
        ),
        VerseCard(verse: day.verseOfDay!, label: 'Стих дня'),
        SectionHeader(
          title: 'План на сегодня',
          trailing: '${day.doneCount} из ${plan.length}',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
          ),
          child: LinearProgressIndicator(
            value: plan.isEmpty ? 0 : day.doneCount / plan.length,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        for (final task in plan)
          DailyTaskTile(
            task: task,
            onToggle: () => _toggle(context, task),
            // Пока открывается только отрывок из Библии.
            onTap: task.type == DailyTaskType.reading
                ? () => context.push(
                    '/bible/${profile.lastReadBookId}/'
                    '${profile.lastReadChapter}',
                  )
                : null,
          ),
      ],
    );
  }
}
