import '../models/community.dart';
import 'result.dart';

/// Контракт хранилища «Вместе»: группы совместного чтения и лента.
///   fetchGroups()   → GET    /groups
///   fetchFeed()     → GET    /feed
///   leaveGroup(id)  → DELETE /groups/{id}/membership (204)
abstract class CommunityRepository {
  Future<Result<List<ReadingGroup>>> fetchGroups();
  Future<Result<List<FriendActivity>>> fetchFeed();
  Future<Result<void>> leaveGroup(int groupId);
}
