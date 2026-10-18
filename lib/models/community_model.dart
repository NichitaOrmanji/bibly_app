import 'package:flutter/foundation.dart';

import '../data/community_repository.dart';
import '../data/result.dart';
import 'community.dart';

/// «Вместе»: группы совместного чтения и лента друзей.
class CommunityModel extends ChangeNotifier {
  CommunityModel(this._repository);

  final CommunityRepository _repository;

  bool _loading = false;
  String? _error;
  List<ReadingGroup> _groups = const [];
  List<FriendActivity> _feed = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<ReadingGroup> get groups => List.unmodifiable(_groups);
  List<FriendActivity> get feed => List.unmodifiable(_feed);

  ReadingGroup? byId(int id) {
    for (final g in _groups) {
      if (g.id == id) return g;
    }
    return null;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    // Два запроса параллельно — ждём оба.
    final (groups, feed) = await (
      _repository.fetchGroups(),
      _repository.fetchFeed(),
    ).wait;
    switch ((groups, feed)) {
      case (Ok(value: final g), Ok(value: final f)):
        _groups = g;
        _feed = f;
      case (Err(:final msg), _) || (_, Err(:final msg)):
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  /// Выйти из группы: группа исчезает из списка на всех экранах.
  Future<String?> leaveGroup(int id) async {
    switch (await _repository.leaveGroup(id)) {
      case Ok():
        _groups = _groups.where((g) => g.id != id).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }
}
