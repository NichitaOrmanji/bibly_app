/// Вид пункта ежедневного плана — по нему выбирается иконка.
enum DailyTaskType { quote, reading, reflection, prayer }

/// Пункт плана на день: цитата, отрывок из Библии, размышление
/// или призыв к молитве.
class DailyTask {
  final String title;
  final String subtitle;
  final int minutes;
  final DailyTaskType type;

  /// Отмечен ли пункт выполненным. В ЛР2 — просто данные из mock,
  /// переключение появится вместе с состоянием (ЛР4).
  final bool isDone;

  const DailyTask({
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.type,
    this.isDone = false,
  });
}
