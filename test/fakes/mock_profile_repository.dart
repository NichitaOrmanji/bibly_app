import 'package:bibly_app/models/user_profile.dart';

import 'mock_data.dart';

import 'package:bibly_app/data/profile_repository.dart';
import 'package:bibly_app/data/result.dart';

import 'mock_network.dart';

/// Профиль в памяти.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository(this._net);

  final MockNetwork _net;
  UserProfile _profile = MockData.user;

  @override
  Future<Result<UserProfile>> fetch() async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    return Ok(_profile);
  }

  @override
  Future<Result<UserProfile>> update(UserProfile profile) async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    _profile = profile;
    return Ok(_profile);
  }
}
