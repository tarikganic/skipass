import 'package:shared_preferences/shared_preferences.dart';

/// Cuva pristupni token i osnovne podatke o sesiji izmedju pokretanja aplikacije.
class TokenStorage {
  static const _tokenKey = 'skipass.access_token';
  static const _expiryKey = 'skipass.token_expires_at';
  static const _usernameKey = 'skipass.username';

  Future<void> save({
    required String token,
    required DateTime expiresAt,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_expiryKey, expiresAt.toIso8601String());
    await prefs.setString(_usernameKey, username);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return null;

    // Istekao token se ne vraca; korisnik se preusmjerava na prijavu.
    final expiry = DateTime.tryParse(prefs.getString(_expiryKey) ?? '');
    if (expiry != null && expiry.isBefore(DateTime.now())) {
      await clear();
      return null;
    }

    return token;
  }

  Future<String?> readUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
    await prefs.remove(_usernameKey);
  }
}
