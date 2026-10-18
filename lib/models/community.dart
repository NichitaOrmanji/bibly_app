/// Группа совместного чтения: название, участники, текущий план и прогресс.
class ReadingGroup {
  /// Номер группы — путешествует в адресе: /together/2.
  final int id;
  final String name;
  final int members;
  final String plan;

  /// Доля пройденного плана, от 0 до 1.
  final double progress;

  /// Имена участников, которые отдаёт хранилище вместе с группой.
  final List<String> memberNames;

  const ReadingGroup(
    this.id,
    this.name,
    this.members,
    this.plan,
    this.progress, {
    this.memberNames = const [],
  });

  ReadingGroup copyWith({List<String>? memberNames}) => ReadingGroup(
    id,
    name,
    members,
    plan,
    progress,
    memberNames: memberNames ?? this.memberNames,
  );
}

/// Событие в ленте друзей: кто, что сделал, когда и (необязательно)
/// запись дневника, которой человек поделился.
class FriendActivity {
  final String name;
  final String action;
  final String timeLabel;
  final String? sharedText;
  final int prayers;

  const FriendActivity({
    required this.name,
    required this.action,
    required this.timeLabel,
    this.sharedText,
    this.prayers = 0,
  });
}
