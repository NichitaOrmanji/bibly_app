import 'package:flutter/foundation.dart';

import '../data/profile_repository.dart';
import '../data/result.dart';
import 'user_profile.dart';

/// Профиль пользователя: читают «Профиль», приветствие в «Моём дне»,
/// «Продолжить чтение» в «Библии»; пишет форма профиля.
class ProfileModel extends ChangeNotifier {
  ProfileModel(this._repository);

  final ProfileRepository _repository;

  bool _loading = false;
  String? _error;
  UserProfile? _profile;

  bool get isLoading => _loading;
  String? get error => _error;
  UserProfile? get profile => _profile;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    switch (await _repository.fetch()) {
      case Ok(:final value):
        _profile = value;
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> update(UserProfile profile) async {
    switch (await _repository.update(profile)) {
      case Ok(:final value):
        _profile = value;
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }
}
