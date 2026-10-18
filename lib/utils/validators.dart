import '../models/bible_book.dart';

/// Правила валидации полей форм. Каждый validator возвращает
/// текст ошибки или null — null означает «значение верное».
/// Ошибку под полем рисует сам TextFormField.
class Validators {
  Validators._();

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Введите e-mail';
    // Правдоподобный формат: что-то@что-то.домен
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Неверный формат e-mail';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 6) return 'Минимум 6 символов';
    return null;
  }

  /// Пароль Скинии — от 4 до 6 цифр.
  static String? tabernaclePin(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Введите пароль Скинии';
    if (!RegExp(r'^\d+$').hasMatch(v)) return 'Только цифры';
    if (v.length < 4) return 'От 4 до 6 цифр';
    return null;
  }

  static String? entryTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Заголовок обязателен';
    if (v.length > 60) return 'Не длиннее 60 символов';
    return null;
  }

  static String? entryText(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Напишите хотя бы пару слов';
    if (v.length < 10) return 'Минимум 10 символов';
    return null;
  }

  /// Ссылка на стих — необязательна; если указана, то в формате
  /// «Ин 3:16» / «1 Кор 13», книга должна существовать,
  /// а глава — не превышать число глав в книге. Список книг приходит
  /// из модели (BibleModel), а не из mock-данных.
  static String? verseReference(String? value, List<BibleBook> books) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // поле необязательное
    final m = RegExp(r'^(\d?\s?[А-Яа-яЁё]+)\s+(\d+)(?::(\d+))?$').firstMatch(v);
    if (m == null) return 'Формат: «Ин 3:16» или «1 Кор 13»';
    // Книги ещё не загружены — проверить можно только формат.
    if (books.isEmpty) return null;
    final abbr = m.group(1)!.replaceAll(' ', '').toLowerCase();
    final matches = books.where((b) => b.abbreviation.toLowerCase() == abbr);
    if (matches.isEmpty) return 'Нет такой книги: «${m.group(1)}»';
    final book = matches.first;
    final chapter = int.parse(m.group(2)!);
    if (chapter < 1 || chapter > book.chapters) {
      return 'В книге «${book.name}» глав: ${book.chapters}';
    }
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Введите имя';
    if (v.length < 2) return 'Имя — минимум 2 буквы';
    return null;
  }

  /// Телефон в Молдове: 9 цифр, начинается с 0 (069123456).
  /// Необязательное поле.
  static String? phone(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return null;
    if (v.length != 9 || !v.startsWith('0')) {
      return '9 цифр, начиная с 0 (например, 069123456)';
    }
    return null;
  }
}
