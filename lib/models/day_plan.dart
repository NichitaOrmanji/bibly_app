import 'daily_task.dart';
import 'verse.dart';

/// Содержание «Моего дня», которое приходит из хранилища:
/// дата, стих дня и 4 шага плана.
class DayPlan {
  final String dateLabel;
  final Verse verseOfDay;
  final List<DailyTask> tasks;

  const DayPlan({
    required this.dateLabel,
    required this.verseOfDay,
    required this.tasks,
  });
}
