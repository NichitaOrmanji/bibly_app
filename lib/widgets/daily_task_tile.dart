import 'package:flutter/material.dart';

import '../models/daily_task.dart';

/// Строка плана на день: иконка вида, название, подпись, длительность
/// и отметка выполнения. Отметка статическая — берётся из данных.
class DailyTaskTile extends StatelessWidget {
  final DailyTask task;

  const DailyTaskTile({super.key, required this.task});

  static IconData _iconFor(DailyTaskType type) {
    switch (type) {
      case DailyTaskType.reading:
        return Icons.menu_book_outlined;
      case DailyTaskType.prayer:
        return Icons.volunteer_activism_outlined;
      case DailyTaskType.reflection:
        return Icons.lightbulb_outline;
      case DailyTaskType.audio:
        return Icons.headphones_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: task.isDone
            ? scheme.secondaryContainer
            : scheme.surfaceContainerHighest,
        child: Icon(
          _iconFor(task.type),
          color: task.isDone
              ? scheme.onSecondaryContainer
              : scheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        task.title,
        style: task.isDone
            ? TextStyle(
                decoration: TextDecoration.lineThrough,
                color: scheme.onSurfaceVariant,
              )
            : null,
      ),
      subtitle: Text('${task.subtitle} · ${task.minutes} мин'),
      trailing: Icon(
        task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: task.isDone ? scheme.primary : scheme.outline,
      ),
    );
  }
}
