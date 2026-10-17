import '../models/bible_book.dart';
import '../models/chapter_verse.dart';
import '../models/community.dart';
import '../models/daily_task.dart';
import '../models/diary_entry.dart';
import '../models/verse.dart';

/// Статические данные для ЛР2. С ЛР5 их заменит бэкенд.
class MockData {
  MockData._();

  // ---------- Мой день ----------

  static const String userName = 'Никита';
  static const String userFullName = 'Никита Орманжи';
  static const String userEmail = 'nikita@example.com';
  static const String memberSince = 'с сентября 2026';

  /// Сколько глав прочитано всего (для профиля).
  static const int chaptersRead = 86;

  static const String todayLabel = 'Суббота, 17 октября';

  /// Сколько дней подряд пользователь открывал план.
  static const int streakDays = 12;

  static const Verse verseOfDay = Verse(
    text: 'Ибо так возлюбил Бог мир, что отдал Сына Своего Единородного, '
        'дабы всякий верующий в Него не погиб, но имел жизнь вечную.',
    reference: 'Ин 3:16',
  );

  /// План на день — всегда 4 шага в одном порядке:
  /// цитата → отрывок из Библии → размышление → призыв к молитве.
  static const List<DailyTask> todayPlan = [
    DailyTask(
      title: 'Цитата дня',
      subtitle: '«Молитва не меняет Бога, но меняет молящегося» — С. Кьеркегор',
      minutes: 1,
      type: DailyTaskType.quote,
      isDone: true,
    ),
    DailyTask(
      title: 'Отрывок из Библии',
      subtitle: 'Ин 3:1–21 · Беседа Иисуса с Никодимом',
      minutes: 7,
      type: DailyTaskType.reading,
      isDone: true,
    ),
    DailyTask(
      title: 'Размышление',
      subtitle: 'Что значит «родиться свыше»?',
      minutes: 5,
      type: DailyTaskType.reflection,
    ),
    DailyTask(
      title: 'Призыв к молитве',
      subtitle: 'Помолитесь о тех, кто ищет ответы, как Никодим',
      minutes: 3,
      type: DailyTaskType.prayer,
    ),
  ];

  // ---------- Библия ----------

  /// Где пользователь остановился в последний раз.
  static const String lastReadBook = 'От Иоанна';
  static const int lastReadChapter = 3;
  static const String translation = 'Синодальный перевод';

  static const String chapterHeading = 'Беседа Иисуса с Никодимом';

  /// Текст главы для экрана чтения (Ин 3, Синодальный перевод —
  /// общественное достояние). Для ЛР2 — фрагмент главы.
  static const List<ChapterVerse> chapterVerses = [
    ChapterVerse(1, 'Между фарисеями был некто, именем Никодим, '
        'один из начальников Иудейских.'),
    ChapterVerse(2, 'Он пришел к Иисусу ночью и сказал Ему: Равви! '
        'мы знаем, что Ты учитель, пришедший от Бога…'),
    ChapterVerse(3, 'Иисус сказал ему в ответ: истинно, истинно говорю '
        'тебе, если кто не родится свыше, не может увидеть Царствия Божия.'),
    ChapterVerse(4, 'Никодим говорит Ему: как может человек родиться, '
        'будучи стар?'),
    ChapterVerse(5, 'Иисус отвечал: истинно, истинно говорю тебе, если кто '
        'не родится от воды и Духа, не может войти в Царствие Божие.'),
    ChapterVerse(6, 'Рожденное от плоти есть плоть, а рожденное от Духа '
        'есть дух.'),
    ChapterVerse(7, 'Не удивляйся тому, что Я сказал тебе: должно вам '
        'родиться свыше.'),
    ChapterVerse(
      16,
      'Ибо так возлюбил Бог мир, что отдал Сына Своего Единородного, дабы '
      'всякий верующий в Него не погиб, но имел жизнь вечную.',
      isHighlighted: true,
    ),
    ChapterVerse(17, 'Ибо не послал Бог Сына Своего в мир, чтобы судить '
        'мир, но чтобы мир спасен был чрез Него.'),
  ];

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

  // ---------- Дневник и Скиния ----------

  /// Обычные записи — открыты в разделе «Дневник».
  static const List<DiaryEntry> diaryEntries = [
    DiaryEntry(
      title: 'Родиться свыше',
      text: 'Сегодня читал беседу Иисуса с Никодимом. Никодим пришёл ночью — '
          'с вопросами, которые боялся задать днём. Мне это знакомо.',
      dateLabel: '17 окт',
      verseReference: 'Ин 3:3',
    ),
    DiaryEntry(
      title: 'Господь — Пастырь мой',
      text: 'Псалом 22 перечитал трижды. «Не убоюсь зла» — записал на '
          'листке и положил в карман перед экзаменом.',
      dateLabel: '16 окт',
      verseReference: 'Пс 22:4',
    ),
    DiaryEntry(
      title: 'Благодарность за неделю',
      text: 'Сдал лабораторную, помирился с братом, впервые за месяц '
          'выспался. Хочу помнить, что хорошего было больше.',
      dateLabel: '14 окт',
    ),
    DiaryEntry(
      title: 'Надейся на Господа',
      text: 'Притчи 3:5 — не полагаться на свой разум. Сложно, когда '
          'привык всё планировать до мелочей.',
      dateLabel: '12 окт',
      verseReference: 'Притч 3:5',
    ),
    DiaryEntry(
      title: 'Встреча малой группы',
      text: 'Обсуждали Послание к Филиппийцам. Андрей сказал, что радость — '
          'это не настроение, а выбор. Запомнилось.',
      dateLabel: '10 окт',
      verseReference: 'Флп 4:4',
    ),
    DiaryEntry(
      title: 'Тишина утром',
      text: 'Попробовал 10 минут без телефона перед чтением. День прошёл '
          'спокойнее, чем обычно.',
      dateLabel: '8 окт',
    ),
    DiaryEntry(
      title: 'Блаженны миротворцы',
      text: 'Нагорная проповедь. Миротворец — не тот, кто избегает '
          'конфликтов, а тот, кто их разрешает.',
      dateLabel: '5 окт',
      verseReference: 'Мф 5:9',
    ),
  ];

  /// Приватные записи — раздел «Скиния», открывается по паролю.
  static const List<DiaryEntry> tabernacleEntries = [
    DiaryEntry(
      title: 'Молитва о маме',
      text: 'Господи, дай маме сил после операции. Научи меня быть рядом, '
          'а не только звонить по выходным.',
      dateLabel: '17 окт',
      isPrivate: true,
    ),
    DiaryEntry(
      title: 'Исповедь',
      text: 'Снова сорвался на сестру из-за пустяка. Хочу научиться '
          'сначала молчать, а потом говорить.',
      dateLabel: '15 окт',
      verseReference: 'Иак 1:19',
      isPrivate: true,
    ),
    DiaryEntry(
      title: 'Страх перед будущим',
      text: 'Не знаю, правильную ли специальность выбрал. Отдаю это Тебе — '
          'покажи путь.',
      dateLabel: '13 окт',
      verseReference: 'Иер 29:11',
      isPrivate: true,
    ),
    DiaryEntry(
      title: 'Ответ на молитву',
      text: 'Месяц молился о работе на лето — сегодня пригласили на '
          'собеседование. Записываю, чтобы не забыть.',
      dateLabel: '11 окт',
      isPrivate: true,
    ),
    DiaryEntry(
      title: 'Прощение',
      text: 'Прощаю Д. за ту историю. Не потому что он прав, а потому что '
          'мне самому простили больше.',
      dateLabel: '9 окт',
      verseReference: 'Еф 4:32',
      isPrivate: true,
    ),
    DiaryEntry(
      title: 'Список молитв',
      text: 'Мама — здоровье. Брат — работа. Лена — экзамены. '
          'Малая группа — единство.',
      dateLabel: '6 окт',
      isPrivate: true,
    ),
  ];

  // ---------- Вместе ----------

  static const List<ReadingGroup> groups = [
    ReadingGroup('Малая группа «Филиппийцы»', 8, 'Послание к Филиппийцам', 0.75),
    ReadingGroup('Студенты УТМ', 23, 'Евангелие от Иоанна за 21 день', 0.43),
    ReadingGroup('Семья Орманжи', 4, 'Псалмы утешения', 0.6),
    ReadingGroup('Утренний кофе и Притчи', 12, 'Притчи — глава в день', 0.32),
    ReadingGroup('Молодёжь церкви «Благодать»', 31, 'Нагорная проповедь', 0.9),
    ReadingGroup('Библия за год 2026', 146, 'Вся Библия за 365 дней', 0.79),
  ];

  static const List<FriendActivity> feed = [
    FriendActivity(
      name: 'Андрей Чобану',
      action: 'закончил план «Нагорная проповедь»',
      timeLabel: '15 мин назад',
      prayers: 6,
    ),
    FriendActivity(
      name: 'Елена Русу',
      action: 'поделилась записью к Флп 4:6',
      timeLabel: '1 ч назад',
      sharedText: 'Перестала тревожиться о сессии, когда начала '
          'записывать молитвы. Список длинный, но на душе тише.',
      prayers: 11,
    ),
    FriendActivity(
      name: 'Максим Бурлаку',
      action: 'читает Ин 3 — день 12 из 21',
      timeLabel: '2 ч назад',
      prayers: 2,
    ),
    FriendActivity(
      name: 'Ольга Попеску',
      action: 'просит молитвы',
      timeLabel: '3 ч назад',
      sharedText: 'Завтра у папы операция. Буду благодарна '
          'за молитвы обо всей нашей семье.',
      prayers: 24,
    ),
    FriendActivity(
      name: 'Даниил Морарь',
      action: '30 дней подряд с Библией',
      timeLabel: 'вчера',
      prayers: 9,
    ),
    FriendActivity(
      name: 'Мария Лупу',
      action: 'поделилась записью к Пс 22:1',
      timeLabel: 'вчера',
      sharedText: 'Господь — Пастырь мой. Перечитала в автобусе '
          'и впервые не спешила.',
      prayers: 7,
    ),
    FriendActivity(
      name: 'Сергей Гуцу',
      action: 'присоединился к группе «Студенты УТМ»',
      timeLabel: '2 дня назад',
      prayers: 3,
    ),
  ];

  // ---------- Поиск ----------

  static const String searchQuery = 'любовь';

  static const List<String> recentSearches = [
    'Пс 22',
    'надежда',
    'мир',
    'Ин 3:16',
    'прощение',
    'радость',
  ];

  /// Результаты по запросу «любовь» (Синодальный перевод).
  static const List<Verse> searchResults = [
    Verse(
      text: 'Кто не любит, тот не познал Бога, потому что Бог есть любовь.',
      reference: '1 Ин 4:8',
    ),
    Verse(
      text: 'Будем любить Его, потому что Он прежде возлюбил нас.',
      reference: '1 Ин 4:19',
    ),
    Verse(
      text: 'Нет больше той любви, как если кто положит душу свою '
          'за друзей своих.',
      reference: 'Ин 15:13',
    ),
    Verse(
      text: 'Любовь не делает ближнему зла; итак любовь есть '
          'исполнение закона.',
      reference: 'Рим 13:10',
    ),
    Verse(
      text: 'Более же всего имейте усердную любовь друг ко другу, потому что '
          'любовь покрывает множество грехов.',
      reference: '1 Пет 4:8',
    ),
    Verse(
      text: 'Любовь долготерпит, милосердствует, любовь не завидует, '
          'любовь не превозносится, не гордится.',
      reference: '1 Кор 13:4',
    ),
    // Стих дня тоже находится по этому запросу.
    verseOfDay,
  ];
}
