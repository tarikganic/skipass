import 'dart:io';

import '../core/api/api_client.dart';
import '../models/user.dart';

/// Prijava za osoblje i administratore. Desktop aplikacija nema registraciju -
/// naloge kreira administrator kroz sekciju Korisnici.
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

  Future<void> logout() async {
    await _api.post('/api/Auth/logout');
  }

  Future<String> uploadProfileImage(File file) async {
    final json = await _api.uploadFile('/api/Files/images/profiles', file);
    return (json as Map<String, dynamic>)['url'] as String;
  }
}
