import '../models/user_profile.dart';
import 'result.dart';

/// Контракт хранилища профиля — вторая пишущая сущность.
///   fetch()          → GET /profile
///   update(profile)  → PUT /profile
abstract class ProfileRepository {
  Future<Result<UserProfile>> fetch();
  Future<Result<UserProfile>> update(UserProfile profile);
}
