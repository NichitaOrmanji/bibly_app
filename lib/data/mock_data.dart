import '../models/daily_task.dart';
import '../models/verse.dart';

/// Статические данные для ЛР2. С ЛР5 их заменит бэкенд.
class MockData {
  MockData._();

  // ---------- Мой день ----------

  static const String userName = 'Никита';

  static const String todayLabel = 'Суббота, 17 октября';

  /// Сколько дней подряд пользователь открывал план.
  static const int streakDays = 12;

  static const Verse verseOfDay = Verse(
    text: 'Ибо так возлюбил Бог мир, что отдал Сына Своего Единородного, '
        'дабы всякий верующий в Него не погиб, но имел жизнь вечную.',
    reference: 'Ин 3:16',
  );

  static const List<DailyTask> todayPlan = [
    DailyTask(
      title: 'Утренняя молитва',
      subtitle: 'Благодарность за новый день',
      minutes: 3,
      type: DailyTaskType.prayer,
      isDone: true,
    ),
    DailyTask(
      title: 'Псалом 22',
      subtitle: 'Господь — Пастырь мой',
      minutes: 2,
      type: DailyTaskType.reading,
      isDone: true,
    ),
    DailyTask(
      title: 'Евангелие от Иоанна, глава 3',
      subtitle: 'Беседа Иисуса с Никодимом',
      minutes: 7,
      type: DailyTaskType.reading,
      isDone: true,
    ),
    DailyTask(
      title: 'Размышление дня',
      subtitle: 'Что значит «родиться свыше»?',
      minutes: 5,
      type: DailyTaskType.reflection,
    ),
    DailyTask(
      title: 'Притчи, глава 3',
      subtitle: 'Надейся на Господа всем сердцем',
      minutes: 4,
      type: DailyTaskType.reading,
    ),
    DailyTask(
      title: 'Аудио: Послание к Филиппийцам 4',
      subtitle: 'Радуйтесь всегда в Господе',
      minutes: 6,
      type: DailyTaskType.audio,
    ),
    DailyTask(
      title: 'Вечерняя молитва',
      subtitle: 'Итоги дня и молитва за близких',
      minutes: 5,
      type: DailyTaskType.prayer,
    ),
  ];
}
