import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cuva izabrani jezik aplikacije (bosanski/engleski) i perzistira izbor
/// lokalno, tako da ostaje isti izmedju pokretanja aplikacije.
class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale';

  Locale _locale = const Locale('bs');

  Locale get locale => _locale;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
