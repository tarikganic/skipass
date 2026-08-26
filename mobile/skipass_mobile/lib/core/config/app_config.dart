/// Konfiguracija aplikacije.
///
/// Adresa API-ja se ne hardkodira, nego se prosljedjuje pri pokretanju:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
/// Podrazumijevana vrijednost je adresa hosta iz Android emulatora.
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  /// Vremensko ogranicenje jednog HTTP zahtjeva.
  static const Duration requestTimeout = Duration(seconds: 20);

  /// Interval osvjezavanja broja neprocitanih notifikacija.
  static const Duration notificationPollInterval = Duration(seconds: 30);

  /// Podrazumijevana velicina stranice na list ekranima.
  static const int pageSize = 20;

  /// Puna adresa slike koja je na serveru spremljena kao relativna putanja.
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$apiBaseUrl$path';
  }
}
