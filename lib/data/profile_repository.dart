import '../models/user_profile.dart';
import 'result.dart';

/// Контракт хранилища профиля — вторая пишущая сущность.
///   fetch()          → GET /me
///   update(profile)  → PUT /me
abstract class ProfileRepository {
  Future<Result<UserProfile>> fetch();
  Future<Result<UserProfile>> update(UserProfile profile);
}
