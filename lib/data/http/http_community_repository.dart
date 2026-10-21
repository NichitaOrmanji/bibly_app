import '../../models/community.dart';
import '../community_repository.dart';
import '../result.dart';
import 'api_client.dart';

/// «Вместе» на сервере: группы чтения и лента друзей.
class HttpCommunityRepository implements CommunityRepository {
  HttpCommunityRepository(this._api);

  final ApiClient _api;

  /// GET /groups → группы, из которых пользователь не вышел.
  @override
  Future<Result<List<ReadingGroup>>> fetchGroups() => _api.get(
    '/groups',
    (j) => [
      for (final g in j as List)
        ReadingGroup.fromJson(g as Map<String, dynamic>),
    ],
  );

  /// GET /feed → события друзей.
  @override
  Future<Result<List<FriendActivity>>> fetchFeed() => _api.get(
    '/feed',
    (j) => [
      for (final a in j as List)
        FriendActivity.fromJson(a as Map<String, dynamic>),
    ],
  );

  /// DELETE /groups/{id}/membership → 204.
  @override
  Future<Result<void>> leaveGroup(int groupId) =>
      _api.delete('/groups/$groupId/membership');
}
