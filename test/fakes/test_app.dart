import 'package:flutter/widgets.dart';

import 'package:bibly_app/data/auth_api.dart';
import 'package:bibly_app/data/result.dart';
import 'package:bibly_app/data/token_store.dart';
import 'package:bibly_app/main.dart';

import 'mock_bible_repository.dart';
import 'mock_community_repository.dart';
import 'mock_daily_repository.dart';
import 'mock_diary_repository.dart';
import 'mock_network.dart';
import 'mock_profile_repository.dart';

/// Вход без сервера: виджет-тесты проверяют экраны, а не сеть.
/// Любые данные, прошедшие валидацию, впускают; token никуда не пишется,
/// но новый сеанс начинается — как у настоящего AuthApi.
class FakeAuthApi extends AuthApi {
  FakeAuthApi() : super('', TokenStore());

  @override
  Future<Result<void>> login(String email, String password) async {
    session.value++;
    return const Ok(null);
  }

  @override
  Future<Result<void>> register(
    String email,
    String password,
    String name,
  ) async {
    session.value++;
    return const Ok(null);
  }

  @override
  Future<void> logout() async {}
}

/// Приложение на тестовых дублёрах: тот же корень композиции createApp,
/// что и в main(), только хранилища — в памяти, а не http.
/// [net] — чтобы тест мог включить аварию.
Widget testApp({AuthApi? auth, MockNetwork? net}) {
  final n = net ?? MockNetwork();
  return createApp(
    auth: auth ?? FakeAuthApi(),
    daily: MockDailyRepository(n),
    diary: MockDiaryRepository(n),
    bible: MockBibleRepository(n),
    community: MockCommunityRepository(n),
    profile: MockProfileRepository(n),
  );
}
