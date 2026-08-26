import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Drzi stanje prijave osoblja/administratora.
///
/// Desktop aplikacija je administrativni dio sistema, pa je prijava skijasa
/// (rola Skier) namjerno odbijena na klijentu iako bi API prihvatio kredencijale -
/// isti obrazac koji API vec primjenjuje kroz role-based autorizaciju ruta.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required ApiClient apiClient,
    required AuthService authService,
    TokenStorage? tokenStorage,
  })  : _api = apiClient,
        _authService = authService,
        _tokenStorage = tokenStorage ?? TokenStorage() {
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
  bool get isAdmin => _user?.role == 'Admin';

  Future<void> restoreSession() async {
    final token = await _tokenStorage.readToken();

    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final user = await _authService.me();
      _applySession(user);
    } on ApiException {
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

      if (session.role == 'Skier') {
        throw ApiException(
          message: 'Ovaj nalog nema pristup desktop administraciji. Prijavite se korisnickim racunom osoblja ili administratora.',
        );
      }

      await _tokenStorage.save(
        token: session.accessToken,
        expiresAt: session.expiresAt,
        username: session.username,
      );

      final user = await _authService.me();
      _applySession(user);
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
      await _authService.logout();
    } on ApiException {
      // Lokalna sesija se ipak brise i ako poziv serveru ne uspije.
    } finally {
      await _tokenStorage.clear();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _setBusy(false);
    }
  }

  void _applySession(AppUser user) {
    if (user.role == 'Skier') {
      _tokenStorage.clear();
      _user = null;
      _status = AuthStatus.unauthenticated;
      return;
    }

    _user = user;
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
