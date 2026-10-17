/// Вид пункта ежедневного плана — по нему выбирается иконка.
enum DailyTaskType { reading, prayer, reflection, audio }

/// Пункт плана на день: чтение, молитва, размышление или аудио.
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
