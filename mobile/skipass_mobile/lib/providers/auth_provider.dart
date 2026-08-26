import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Drzi stanje prijave i podatke o trenutnom korisniku.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required ApiClient apiClient,
    required AuthService authService,
    TokenStorage? tokenStorage,
  })  : _api = apiClient,
        _authService = authService,
        _tokenStorage = tokenStorage ?? TokenStorage() {
    // Kada server odbije token, korisnik se odmah vraca na ekran prijave.
    _api.onUnauthorized = _handleUnauthorized;
  }

  final ApiClient _api;
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  bool _isBusy = false;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Provjerava postoji li vazeca sesija pri pokretanju aplikacije.
  Future<void> restoreSession() async {
    final token = await _tokenStorage.readToken();

    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      _user = await _authService.me();
      _status = AuthStatus.authenticated;
    } on ApiException {
      // Token je odbijen ili je korisnik deaktiviran.
      await _tokenStorage.clear();
      _user = null;
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _setBusy(true);
    try {
      final session = await _authService.login(username, password);
      await _persist(session);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> register({
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
    _setBusy(true);
    try {
      final session = await _authService.register(
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phone: phone,
        birthDate: birthDate,
        cityId: cityId,
      );
      await _persist(session);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> refreshUser() async {
    if (!isAuthenticated) return;
    _user = await _authService.me();
    notifyListeners();
  }

  void applyUpdatedUser(AppUser user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    _setBusy(true);
    try {
      // Odjava se prijavljuje serveru kako bi token bio stvarno ponisten.
      await _authService.logout();
    } on ApiException {
      // Cak i ako poziv ne uspije, lokalna sesija se mora ocistiti.
    } finally {
      await _tokenStorage.clear();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _setBusy(false);
    }
  }

  Future<void> _persist(AuthSession session) async {
    await _tokenStorage.save(
      token: session.accessToken,
      expiresAt: session.expiresAt,
      username: session.username,
    );

    _user = await _authService.me();
    _status = AuthStatus.authenticated;
  }

  void _handleUnauthorized() {
    if (_status == AuthStatus.unauthenticated) return;

    _tokenStorage.clear();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
