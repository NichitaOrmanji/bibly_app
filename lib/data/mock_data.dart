import '../models/bible_book.dart';
import '../models/chapter_verse.dart';
import '../models/community.dart';
import '../models/daily_task.dart';
import '../models/diary_entry.dart';
import '../models/user_profile.dart';
import '../models/verse.dart';

/// Seed-данные временного хранилища. С ЛР4 их импортируют ТОЛЬКО
/// mock-репозитории (lib/data/mock/); с ЛР5 их заменит бэкенд.
class MockData {
  MockData._();

  // ---------- Профиль ----------

  static const UserProfile user = UserProfile(
    name: 'Никита Орманжи',
    email: 'nikita@example.com',
    memberSince: 'с сентября 2026',
    streakDays: 12,
    chaptersRead: 86,
    lastReadBookId: 43, // От Иоанна
    lastReadChapter: 3,
    translation: 'Синодальный',
    textSize: 'Средний',
    reminderTime: 'каждый день в 07:30',
    reminderOn: true,
    shareWithGroup: true,
    language: 'Русский',
  );

  // ---------- Мой день ----------

  static const String todayLabel = 'Суббота, 17 октября';

  static const Verse verseOfDay = Verse(
    text:
        'Ибо так возлюбил Бог мир, что отдал Сына Своего Единородного, '
        'дабы всякий верующий в Него не погиб, но имел жизнь вечную.',
    reference: 'Ин 3:16',
  );

  /// План на день — всегда 4 шага в одном порядке:
  /// цитата → отрывок из Библии → размышление → призыв к молитве.
  static const List<DailyTask> todayPlan = [
    DailyTask(
      id: 1,
      title: 'Цитата дня',
      subtitle: '«Молитва не меняет Бога, но меняет молящегося» — С. Кьеркегор',
      minutes: 1,
      type: DailyTaskType.quote,
      isDone: true,
    ),
    DailyTask(
      id: 2,
      title: 'Отрывок из Библии',
      subtitle: 'Ин 3:1–21 · Беседа Иисуса с Никодимом',
      minutes: 7,
      type: DailyTaskType.reading,
      isDone: true,
    ),
    DailyTask(
      id: 3,
      title: 'Размышление',
      subtitle: 'Что значит «родиться свыше»?',
      minutes: 5,
      type: DailyTaskType.reflection,
    ),
    DailyTask(
      id: 4,
      title: 'Призыв к молитве',
      subtitle: 'Помолитесь о тех, кто ищет ответы, как Никодим',
      minutes: 3,
      type: DailyTaskType.prayer,
    ),
  ];

  // ---------- Библия ----------

  static const String chapterHeading = 'Беседа Иисуса с Никодимом';

  /// Текст главы для экрана чтения (Ин 3, Синодальный перевод —
  /// общественное достояние). Для ЛР2 — фрагмент главы.
  static const List<ChapterVerse> chapterVerses = [
    ChapterVerse(
      1,
      'Между фарисеями был некто, именем Никодим, '
      'один из начальников Иудейских.',
    ),
    ChapterVerse(
      2,
      'Он пришел к Иисусу ночью и сказал Ему: Равви! '
      'мы знаем, что Ты учитель, пришедший от Бога…',
    ),
    ChapterVerse(
      3,
      'Иисус сказал ему в ответ: истинно, истинно говорю '
      'тебе, если кто не родится свыше, не может увидеть Царствия Божия.',
    ),
    ChapterVerse(
      4,
      'Никодим говорит Ему: как может человек родиться, '
      'будучи стар?',
    ),
    ChapterVerse(
      5,
      'Иисус отвечал: истинно, истинно говорю тебе, если кто '
      'не родится от воды и Духа, не может войти в Царствие Божие.',
    ),
    ChapterVerse(
      6,
      'Рожденное от плоти есть плоть, а рожденное от Духа '
      'есть дух.',
    ),
    ChapterVerse(
      7,
      'Не удивляйся тому, что Я сказал тебе: должно вам '
      'родиться свыше.',
    ),
    ChapterVerse(
      16,
      'Ибо так возлюбил Бог мир, что отдал Сына Своего Единородного, дабы '
      'всякий верующий в Него не погиб, но имел жизнь вечную.',
      isHighlighted: true,
    ),
    ChapterVerse(
      17,
      'Ибо не послал Бог Сына Своего в мир, чтобы судить '
      'мир, но чтобы мир спасен был чрез Него.',
    ),
  ];

  /// 66 книг в синодальном порядке.
  static const List<BibleBook> books = [
    // Ветхий Завет — 39 книг
    BibleBook(1, 'Бытие', 'Быт', 50, Testament.old),
    BibleBook(2, 'Исход', 'Исх', 40, Testament.old),
    BibleBook(3, 'Левит', 'Лев', 27, Testament.old),
    BibleBook(4, 'Числа', 'Чис', 36, Testament.old),
    BibleBook(5, 'Второзаконие', 'Втор', 34, Testament.old),
    BibleBook(6, 'Иисус Навин', 'Нав', 24, Testament.old),
    BibleBook(7, 'Судей', 'Суд', 21, Testament.old),
    BibleBook(8, 'Руфь', 'Руф', 4, Testament.old),
    BibleBook(9, '1-я Царств', '1Цар', 31, Testament.old),
    BibleBook(10, '2-я Царств', '2Цар', 24, Testament.old),
    BibleBook(11, '3-я Царств', '3Цар', 22, Testament.old),
    BibleBook(12, '4-я Царств', '4Цар', 25, Testament.old),
    BibleBook(13, '1-я Паралипоменон', '1Пар', 29, Testament.old),
    BibleBook(14, '2-я Паралипоменон', '2Пар', 36, Testament.old),
    BibleBook(15, 'Ездра', 'Езд', 10, Testament.old),
    BibleBook(16, 'Неемия', 'Неем', 13, Testament.old),
    BibleBook(17, 'Есфирь', 'Есф', 10, Testament.old),
    BibleBook(18, 'Иов', 'Иов', 42, Testament.old),
    BibleBook(19, 'Псалтирь', 'Пс', 150, Testament.old),
    BibleBook(20, 'Притчи', 'Притч', 31, Testament.old),
    BibleBook(21, 'Екклесиаст', 'Еккл', 12, Testament.old),
    BibleBook(22, 'Песнь песней', 'Песн', 8, Testament.old),
    BibleBook(23, 'Исаия', 'Ис', 66, Testament.old),
    BibleBook(24, 'Иеремия', 'Иер', 52, Testament.old),
    BibleBook(25, 'Плач Иеремии', 'Плач', 5, Testament.old),
    BibleBook(26, 'Иезекииль', 'Иез', 48, Testament.old),
    BibleBook(27, 'Даниил', 'Дан', 12, Testament.old),
    BibleBook(28, 'Осия', 'Ос', 14, Testament.old),
    BibleBook(29, 'Иоиль', 'Иоил', 3, Testament.old),
    BibleBook(30, 'Амос', 'Ам', 9, Testament.old),
    BibleBook(31, 'Авдий', 'Авд', 1, Testament.old),
    BibleBook(32, 'Иона', 'Ион', 4, Testament.old),
    BibleBook(33, 'Михей', 'Мих', 7, Testament.old),
    BibleBook(34, 'Наум', 'Наум', 3, Testament.old),
    BibleBook(35, 'Аввакум', 'Авв', 3, Testament.old),
    BibleBook(36, 'Софония', 'Соф', 3, Testament.old),
    BibleBook(37, 'Аггей', 'Агг', 2, Testament.old),
    BibleBook(38, 'Захария', 'Зах', 14, Testament.old),
    BibleBook(39, 'Малахия', 'Мал', 4, Testament.old),
    // Новый Завет — 27 книг
    BibleBook(40, 'От Матфея', 'Мф', 28, Testament.newTestament),
    BibleBook(41, 'От Марка', 'Мк', 16, Testament.newTestament),
    BibleBook(42, 'От Луки', 'Лк', 24, Testament.newTestament),
    BibleBook(43, 'От Иоанна', 'Ин', 21, Testament.newTestament),
    BibleBook(44, 'Деяния апостолов', 'Деян', 28, Testament.newTestament),
    BibleBook(45, 'Иакова', 'Иак', 5, Testament.newTestament),
    BibleBook(46, '1-е Петра', '1Пет', 5, Testament.newTestament),
    BibleBook(47, '2-е Петра', '2Пет', 3, Testament.newTestament),
    BibleBook(48, '1-е Иоанна', '1Ин', 5, Testament.newTestament),
    BibleBook(49, '2-е Иоанна', '2Ин', 1, Testament.newTestament),
    BibleBook(50, '3-е Иоанна', '3Ин', 1, Testament.newTestament),
    BibleBook(51, 'Иуды', 'Иуд', 1, Testament.newTestament),
    BibleBook(52, 'К Римлянам', 'Рим', 16, Testament.newTestament),
    BibleBook(53, '1-е Коринфянам', '1Кор', 16, Testament.newTestament),
    BibleBook(54, '2-е Коринфянам', '2Кор', 13, Testament.newTestament),
    BibleBook(55, 'К Галатам', 'Гал', 6, Testament.newTestament),
    BibleBook(56, 'К Ефесянам', 'Еф', 6, Testament.newTestament),
    BibleBook(57, 'К Филиппийцам', 'Флп', 4, Testament.newTestament),
    BibleBook(58, 'К Колоссянам', 'Кол', 4, Testament.newTestament),
    BibleBook(59, '1-е Фессалоникийцам', '1Фес', 5, Testament.newTestament),
    BibleBook(60, '2-е Фессалоникийцам', '2Фес', 3, Testament.newTestament),
    BibleBook(61, '1-е Тимофею', '1Тим', 6, Testament.newTestament),
    BibleBook(62, '2-е Тимофею', '2Тим', 4, Testament.newTestament),
    BibleBook(63, 'К Титу', 'Тит', 3, Testament.newTestament),
    BibleBook(64, 'К Филимону', 'Флм', 1, Testament.newTestament),
    BibleBook(65, 'К Евреям', 'Евр', 13, Testament.newTestament),
    BibleBook(66, 'Откровение', 'Откр', 22, Testament.newTestament),
  ];

  // ---------- Дневник и Скиния ----------

  /// Обычные записи — открыты в разделе «Дневник».
  static const List<DiaryEntry> diaryEntries = [
    DiaryEntry(
      id: 1,
      title: 'Родиться свыше',
      text:
          'Сегодня читал беседу Иисуса с Никодимом. Никодим пришёл ночью — '
          'с вопросами, которые боялся задать днём. Мне это знакомо.',
      dateLabel: '17 окт',
      verseReference: 'Ин 3:3',
    ),
    DiaryEntry(
      id: 2,
      title: 'Господь — Пастырь мой',
      text:
          'Псалом 22 перечитал трижды. «Не убоюсь зла» — записал на '
          'листке и положил в карман перед экзаменом.',
      dateLabel: '16 окт',
      verseReference: 'Пс 22:4',
    ),
    DiaryEntry(
      id: 3,
      title: 'Благодарность за неделю',
      text:
          'Сдал лабораторную, помирился с братом, впервые за месяц '
          'выспался. Хочу помнить, что хорошего было больше.',
      dateLabel: '14 окт',
    ),
    DiaryEntry(
      id: 4,
      title: 'Надейся на Господа',
      text:
          'Притчи 3:5 — не полагаться на свой разум. Сложно, когда '
          'привык всё планировать до мелочей.',
      dateLabel: '12 окт',
      verseReference: 'Притч 3:5',
    ),
    DiaryEntry(
      id: 5,
      title: 'Встреча малой группы',
      text:
          'Обсуждали Послание к Филиппийцам. Андрей сказал, что радость — '
          'это не настроение, а выбор. Запомнилось.',
      dateLabel: '10 окт',
      verseReference: 'Флп 4:4',
    ),
    DiaryEntry(
      id: 6,
      title: 'Тишина утром',
      text:
          'Попробовал 10 минут без телефона перед чтением. День прошёл '
          'спокойнее, чем обычно.',
      dateLabel: '8 окт',
    ),
    DiaryEntry(
      id: 7,
      title: 'Блаженны миротворцы',
      text:
          'Нагорная проповедь. Миротворец — не тот, кто избегает '
          'конфликтов, а тот, кто их разрешает.',
      dateLabel: '5 окт',
      verseReference: 'Мф 5:9',
    ),
  ];

  /// Приватные записи — раздел «Скиния», открывается по паролю.
  static const List<DiaryEntry> tabernacleEntries = [
    DiaryEntry(
      id: 101,
      title: 'Молитва о маме',
      text:
          'Господи, дай маме сил после операции. Научи меня быть рядом, '
          'а не только звонить по выходным.',
      dateLabel: '17 окт',
      isPrivate: true,
    ),
    DiaryEntry(
      id: 102,
      title: 'Исповедь',
      text:
          'Снова сорвался на сестру из-за пустяка. Хочу научиться '
          'сначала молчать, а потом говорить.',
      dateLabel: '15 окт',
      verseReference: 'Иак 1:19',
      isPrivate: true,
    ),
    DiaryEntry(
      id: 103,
      title: 'Страх перед будущим',
      text:
          'Не знаю, правильную ли специальность выбрал. Отдаю это Тебе — '
          'покажи путь.',
      dateLabel: '13 окт',
      verseReference: 'Иер 29:11',
      isPrivate: true,
    ),
    DiaryEntry(
      id: 104,
      title: 'Ответ на молитву',
      text:
          'Месяц молился о работе на лето — сегодня пригласили на '
          'собеседование. Записываю, чтобы не забыть.',
      dateLabel: '11 окт',
      isPrivate: true,
    ),
    DiaryEntry(
      id: 105,
      title: 'Прощение',
      text:
          'Прощаю Д. за ту историю. Не потому что он прав, а потому что '
          'мне самому простили больше.',
      dateLabel: '9 окт',
      verseReference: 'Еф 4:32',
      isPrivate: true,
    ),
    DiaryEntry(
      id: 106,
      title: 'Список молитв',
      text:
          'Мама — здоровье. Брат — работа. Лена — экзамены. '
          'Малая группа — единство.',
      dateLabel: '6 окт',
      isPrivate: true,
    ),
  ];

  // ---------- Вместе ----------

  static const List<ReadingGroup> groups = [
    ReadingGroup(
      1,
      'Малая группа «Филиппийцы»',
      8,
      'Послание к Филиппийцам',
      0.75,
    ),
    ReadingGroup(2, 'Студенты УТМ', 23, 'Евангелие от Иоанна за 21 день', 0.43),
    ReadingGroup(3, 'Семья Орманжи', 4, 'Псалмы утешения', 0.6),
    ReadingGroup(
      4,
      'Утренний кофе и Притчи',
      12,
      'Притчи — глава в день',
      0.32,
    ),
    ReadingGroup(
      5,
      'Молодёжь церкви «Благодать»',
      31,
      'Нагорная проповедь',
      0.9,
    ),
    ReadingGroup(6, 'Библия за год 2026', 146, 'Вся Библия за 365 дней', 0.79),
  ];

  /// Участники групп (общий список для mock-данных).
  static const List<String> groupMembers = [
    'Никита Орманжи',
    'Андрей Чобану',
    'Елена Русу',
    'Максим Бурлаку',
    'Ольга Попеску',
    'Даниил Морарь',
    'Мария Лупу',
    'Сергей Гуцу',
    'Ирина Ткачук',
    'Виктор Йордаке',
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
      sharedText:
          'Перестала тревожиться о сессии, когда начала '
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
      sharedText:
          'Завтра у папы операция. Буду благодарна '
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
      sharedText:
          'Господь — Пастырь мой. Перечитала в автобусе '
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
      text:
          'Нет больше той любви, как если кто положит душу свою '
          'за друзей своих.',
      reference: 'Ин 15:13',
    ),
    Verse(
      text:
          'Любовь не делает ближнему зла; итак любовь есть '
          'исполнение закона.',
      reference: 'Рим 13:10',
    ),
    Verse(
      text:
          'Более же всего имейте усердную любовь друг ко другу, потому что '
          'любовь покрывает множество грехов.',
      reference: '1 Пет 4:8',
    ),
    Verse(
      text:
          'Любовь долготерпит, милосердствует, любовь не завидует, '
          'любовь не превозносится, не гордится.',
      reference: '1 Кор 13:4',
    ),
    // Стих дня тоже находится по этому запросу.
    verseOfDay,
  ];
}
