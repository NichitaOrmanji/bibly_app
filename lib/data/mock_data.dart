import '../models/bible_book.dart';
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

  // ---------- Библия ----------

  /// Где пользователь остановился в последний раз.
  static const String lastReadBook = 'От Иоанна';
  static const int lastReadChapter = 3;
  static const String translation = 'Синодальный перевод';

  /// 66 книг в синодальном порядке.
  static const List<BibleBook> books = [
    // Ветхий Завет — 39 книг
    BibleBook('Бытие', 'Быт', 50, Testament.old),
    BibleBook('Исход', 'Исх', 40, Testament.old),
    BibleBook('Левит', 'Лев', 27, Testament.old),
    BibleBook('Числа', 'Чис', 36, Testament.old),
    BibleBook('Второзаконие', 'Втор', 34, Testament.old),
    BibleBook('Иисус Навин', 'Нав', 24, Testament.old),
    BibleBook('Судей', 'Суд', 21, Testament.old),
    BibleBook('Руфь', 'Руф', 4, Testament.old),
    BibleBook('1-я Царств', '1Цар', 31, Testament.old),
    BibleBook('2-я Царств', '2Цар', 24, Testament.old),
    BibleBook('3-я Царств', '3Цар', 22, Testament.old),
    BibleBook('4-я Царств', '4Цар', 25, Testament.old),
    BibleBook('1-я Паралипоменон', '1Пар', 29, Testament.old),
    BibleBook('2-я Паралипоменон', '2Пар', 36, Testament.old),
    BibleBook('Ездра', 'Езд', 10, Testament.old),
    BibleBook('Неемия', 'Неем', 13, Testament.old),
    BibleBook('Есфирь', 'Есф', 10, Testament.old),
    BibleBook('Иов', 'Иов', 42, Testament.old),
    BibleBook('Псалтирь', 'Пс', 150, Testament.old),
    BibleBook('Притчи', 'Притч', 31, Testament.old),
    BibleBook('Екклесиаст', 'Еккл', 12, Testament.old),
    BibleBook('Песнь песней', 'Песн', 8, Testament.old),
    BibleBook('Исаия', 'Ис', 66, Testament.old),
    BibleBook('Иеремия', 'Иер', 52, Testament.old),
    BibleBook('Плач Иеремии', 'Плач', 5, Testament.old),
    BibleBook('Иезекииль', 'Иез', 48, Testament.old),
    BibleBook('Даниил', 'Дан', 12, Testament.old),
    BibleBook('Осия', 'Ос', 14, Testament.old),
    BibleBook('Иоиль', 'Иоил', 3, Testament.old),
    BibleBook('Амос', 'Ам', 9, Testament.old),
    BibleBook('Авдий', 'Авд', 1, Testament.old),
    BibleBook('Иона', 'Ион', 4, Testament.old),
    BibleBook('Михей', 'Мих', 7, Testament.old),
    BibleBook('Наум', 'Наум', 3, Testament.old),
    BibleBook('Аввакум', 'Авв', 3, Testament.old),
    BibleBook('Софония', 'Соф', 3, Testament.old),
    BibleBook('Аггей', 'Агг', 2, Testament.old),
    BibleBook('Захария', 'Зах', 14, Testament.old),
    BibleBook('Малахия', 'Мал', 4, Testament.old),
    // Новый Завет — 27 книг
    BibleBook('От Матфея', 'Мф', 28, Testament.newTestament),
    BibleBook('От Марка', 'Мк', 16, Testament.newTestament),
    BibleBook('От Луки', 'Лк', 24, Testament.newTestament),
    BibleBook('От Иоанна', 'Ин', 21, Testament.newTestament),
    BibleBook('Деяния апостолов', 'Деян', 28, Testament.newTestament),
    BibleBook('Иакова', 'Иак', 5, Testament.newTestament),
    BibleBook('1-е Петра', '1Пет', 5, Testament.newTestament),
    BibleBook('2-е Петра', '2Пет', 3, Testament.newTestament),
    BibleBook('1-е Иоанна', '1Ин', 5, Testament.newTestament),
    BibleBook('2-е Иоанна', '2Ин', 1, Testament.newTestament),
    BibleBook('3-е Иоанна', '3Ин', 1, Testament.newTestament),
    BibleBook('Иуды', 'Иуд', 1, Testament.newTestament),
    BibleBook('К Римлянам', 'Рим', 16, Testament.newTestament),
    BibleBook('1-е Коринфянам', '1Кор', 16, Testament.newTestament),
    BibleBook('2-е Коринфянам', '2Кор', 13, Testament.newTestament),
    BibleBook('К Галатам', 'Гал', 6, Testament.newTestament),
    BibleBook('К Ефесянам', 'Еф', 6, Testament.newTestament),
    BibleBook('К Филиппийцам', 'Флп', 4, Testament.newTestament),
    BibleBook('К Колоссянам', 'Кол', 4, Testament.newTestament),
    BibleBook('1-е Фессалоникийцам', '1Фес', 5, Testament.newTestament),
    BibleBook('2-е Фессалоникийцам', '2Фес', 3, Testament.newTestament),
    BibleBook('1-е Тимофею', '1Тим', 6, Testament.newTestament),
    BibleBook('2-е Тимофею', '2Тим', 4, Testament.newTestament),
    BibleBook('К Титу', 'Тит', 3, Testament.newTestament),
    BibleBook('К Филимону', 'Флм', 1, Testament.newTestament),
    BibleBook('К Евреям', 'Евр', 13, Testament.newTestament),
    BibleBook('Откровение', 'Откр', 22, Testament.newTestament),
  ];
}
