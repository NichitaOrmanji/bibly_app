import 'package:flutter/material.dart';

import '../models/daily_task.dart';

/// Строка плана на день: иконка вида, название, подпись, длительность
/// и отметка выполнения. Нажатие на отметку вызывает [onToggle].
class DailyTaskTile extends StatelessWidget {
  final DailyTask task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const DailyTaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
  });

  static IconData _iconFor(DailyTaskType type) {
    switch (type) {
      case DailyTaskType.quote:
        return Icons.format_quote;
      case DailyTaskType.reading:
        return Icons.menu_book_outlined;
      case DailyTaskType.reflection:
        return Icons.lightbulb_outline;
      case DailyTaskType.prayer:
        return Icons.volunteer_activism_outlined;
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
      trailing: IconButton(
        tooltip: task.isDone ? 'Снять отметку' : 'Отметить выполненным',
        onPressed: onToggle,
        icon: Icon(
          task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isDone ? scheme.primary : scheme.outline,
        ),
      ),
      onTap: onTap,
    );
  }
}
