/// Вид пункта ежедневного плана — по нему выбирается иконка.
enum DailyTaskType { quote, reading, reflection, prayer }

/// Пункт плана на день: цитата, отрывок из Библии, размышление
/// или призыв к молитве.
class DailyTask {
  final int id;
  final String title;
  final String subtitle;
  final int minutes;
  final DailyTaskType type;

  /// Отмечен ли пункт выполненным.
  final bool isDone;

  const DailyTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.type,
    this.isDone = false,
  });

  /// Из JSON сервера (ЛР5). Вид приходит строкой: 'quote', 'reading'…
  /// Неизвестный вид — ответ вне контракта: FormatException, а не падение.
  factory DailyTask.fromJson(Map<String, dynamic> j) {
    final type = DailyTaskType.values.asNameMap()[j['type'] as String];
    if (type == null) throw FormatException('Неизвестный вид: ${j['type']}');
    return DailyTask(
      id: j['id'] as int,
      title: j['title'] as String,
      subtitle: j['subtitle'] as String? ?? '',
      minutes: j['minutes'] as int,
      type: type,
      isDone: j['isDone'] as bool? ?? false,
    );
  }

  /// Тот же пункт с другой отметкой — объекты неизменяемы,
  /// поэтому «изменить» значит создать копию.
  DailyTask copyWith({bool? isDone}) => DailyTask(
    id: id,
    title: title,
    subtitle: subtitle,
    minutes: minutes,
    type: type,
    isDone: isDone ?? this.isDone,
  );
}
