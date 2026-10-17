/// Группа совместного чтения: название, участники, текущий план и прогресс.
class ReadingGroup {
  final String name;
  final int members;
  final String plan;

  /// Доля пройденного плана, от 0 до 1.
  final double progress;

  const ReadingGroup(this.name, this.members, this.plan, this.progress);
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
