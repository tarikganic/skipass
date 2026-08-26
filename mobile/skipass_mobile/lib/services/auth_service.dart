import 'dart:io';

import '../core/api/api_client.dart';
import '../models/user.dart';

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  Future<AuthSession> login(String username, String password) async {
    final json = await _api.post('/api/Auth/login', body: {
      'username': username,
      'password': password,
    });
    return AuthSession.fromJson(json as Map<String, dynamic>);
  }

  Future<AuthSession> register({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
    DateTime? birthDate,
    int? cityId,
  }) async {
    final json = await _api.post('/api/Auth/register', body: {
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String(),
      'cityId': cityId,
    });
    return AuthSession.fromJson(json as Map<String, dynamic>);
  }

  Future<AppUser> me() async {
    final json = await _api.get('/api/Auth/me');
    return AppUser.fromJson(json as Map<String, dynamic>);
  }

  Future<AppUser> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    DateTime? birthDate,
    String? profileImageUrl,
    int? cityId,
  }) async {
    final json = await _api.put('/api/Auth/me', body: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'cityId': cityId,
    });
    return AppUser.fromJson(json as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    await _api.post('/api/Auth/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    });
  }

  /// Vraca kod za reset kada API radi u razvojnom okruzenju, inace null.
  Future<String?> forgotPassword(String email) async {
    final json = await _api.post('/api/Auth/forgot-password', body: {'email': email});
    if (json is Map<String, dynamic>) {
      return json['developmentToken'] as String?;
    }
    return null;
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    await _api.post('/api/Auth/reset-password', body: {
      'email': email,
      'token': token,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    });
  }

  Future<void> logout() async {
    await _api.post('/api/Auth/logout');
  }

  /// Salje sliku profila i vraca relativnu putanju koju treba spremiti uz korisnika.
  Future<String> uploadProfileImage(File file) async {
    final json = await _api.uploadFile('/api/Files/images/profiles', file);
    return (json as Map<String, dynamic>)['url'] as String;
  }
}
