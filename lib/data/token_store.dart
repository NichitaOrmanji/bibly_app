import 'package:shared_preferences/shared_preferences.dart';

/// Пропуск (JWT token) поверх shared_preferences. Остальной код не знает,
/// где он хранится: только этот файл говорит с prefs.
///
/// Пароль здесь не хранится НИКОГДА: token заменим и истекает,
/// а пароль — ключ от всего дома.
class TokenStore {
  static const _key = 'auth_token'; // ключ — константа, в одном месте

  /// null — пользователь не вошёл.
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  /// login/register → setString.
  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  /// logout и 401: мёртвый пропуск выбрасывают.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
