import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the logged-in session (tokens + raw user JSON) so the app can
/// restore it on next launch without asking for credentials again.
class AuthStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userJsonKey = 'logged_in_user';

  static const _storage = FlutterSecureStorage();

  Future<void> saveSession({required String accessToken, required String refreshToken, required String userJson}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userJsonKey, value: userJson);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> updateAccessToken(String accessToken) => _storage.write(key: _accessTokenKey, value: accessToken);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<String?> readUserJson() => _storage.read(key: _userJsonKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userJsonKey);
  }
}
