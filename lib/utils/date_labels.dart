/// Короткая дата для записей: «18 окт».
String shortDateLabel(DateTime date) {
  const months = [
    'янв',
    'фев',
    'мар',
    'апр',
    'мая',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];
  return '${date.day} ${months[date.month - 1]}';
}
