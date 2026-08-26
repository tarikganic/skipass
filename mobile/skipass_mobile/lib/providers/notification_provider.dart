import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../core/config/app_config.dart';
import '../services/engagement_service.dart';

/// Prati broj neprocitanih notifikacija.
///
/// Osvjezavanje je automatsko, kroz periodicni poll, kako korisnik ne bi
/// morao rucno povlaciti listu da bi vidio nove notifikacije.
class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._engagementService);

  final EngagementService _engagementService;

  Timer? _timer;
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  void startPolling() {
    _timer?.cancel();
    refresh();
    _timer = Timer.periodic(AppConfig.notificationPollInterval, (_) => refresh());
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      final count = await _engagementService.unreadNotificationCount();
      if (count != _unreadCount) {
        _unreadCount = count;
        notifyListeners();
      }
    } on ApiException {
      // Neuspjelo osvjezavanje brojaca ne smije prekidati rad aplikacije.
    }
  }

  Future<void> markAllRead() async {
    await _engagementService.markAllNotificationsRead();
    _unreadCount = 0;
    notifyListeners();
  }

  void decrement() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
