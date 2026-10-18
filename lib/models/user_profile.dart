/// Профиль пользователя: личные данные, статистика и настройки.
class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String about;
  final String memberSince;

  final int streakDays;
  final int chaptersRead;

  /// Где пользователь остановился: «Продолжить чтение».
  final int lastReadBookId;
  final int lastReadChapter;

  // Настройки
  final String translation;
  final String textSize;
  final String reminderTime;
  final bool reminderOn;
  final bool shareWithGroup;
  final String language;

  const UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.about = '',
    required this.memberSince,
    required this.streakDays,
    required this.chaptersRead,
    required this.lastReadBookId,
    required this.lastReadChapter,
    required this.translation,
    required this.textSize,
    required this.reminderTime,
    required this.reminderOn,
    required this.shareWithGroup,
    required this.language,
  });

  /// Имя для приветствия: «Никита Орманжи» → «Никита».
  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  /// Копия с изменёнными полями из формы профиля.
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? about,
  }) => UserProfile(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    about: about ?? this.about,
    memberSince: memberSince,
    streakDays: streakDays,
    chaptersRead: chaptersRead,
    lastReadBookId: lastReadBookId,
    lastReadChapter: lastReadChapter,
    translation: translation,
    textSize: textSize,
    reminderTime: reminderTime,
    reminderOn: reminderOn,
    shareWithGroup: shareWithGroup,
    language: language,
  );
}
