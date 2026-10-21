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

  /// Из JSON сервера (ЛР5): GET /plans/today.
  factory DayPlan.fromJson(Map<String, dynamic> j) => DayPlan(
    dateLabel: j['dateLabel'] as String,
    verseOfDay: Verse.fromJson(j['verseOfDay'] as Map<String, dynamic>),
    tasks: [
      for (final t in j['tasks'] as List)
        DailyTask.fromJson(t as Map<String, dynamic>),
    ],
  );
}
