import '../../models/user_profile.dart';
import '../profile_repository.dart';
import '../result.dart';
import 'api_client.dart';

/// Профиль на сервере: имя и email — из аккаунта, остальное — настройки.
class HttpProfileRepository implements ProfileRepository {
  HttpProfileRepository(this._api);

  final ApiClient _api;

  static UserProfile _profile(Object? j) =>
      UserProfile.fromJson(j as Map<String, dynamic>);

  /// GET /profile.
  @override
  Future<Result<UserProfile>> fetch() => _api.get('/profile', _profile);

  /// PUT /profile {name, email, phone, about}; чужой email → 409 → Err.
  @override
  Future<Result<UserProfile>> update(UserProfile profile) =>
      _api.put('/profile', profile.toJson(), _profile);
}
