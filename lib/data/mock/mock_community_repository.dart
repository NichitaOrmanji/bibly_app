import '../../models/community.dart';
import '../community_repository.dart';
import '../mock_data.dart';
import '../result.dart';
import 'mock_network.dart';

/// Группы и лента в памяти.
class MockCommunityRepository implements CommunityRepository {
  MockCommunityRepository(this._net);

  final MockNetwork _net;
  final List<ReadingGroup> _groups = List.of(MockData.groups);

  @override
  Future<Result<List<ReadingGroup>>> fetchGroups() async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    return Ok(List.of(_groups));
  }

  @override
  Future<Result<List<FriendActivity>>> fetchFeed() async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    return Ok(List.of(MockData.feed));
  }

  @override
  Future<Result<void>> leaveGroup(int groupId) async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    final before = _groups.length;
    _groups.removeWhere((g) => g.id == groupId);
    if (_groups.length == before) return const Err('Группа не существует');
    return const Ok(null);
  }
}
