/// Konfiguracija aplikacije.
///
/// Adresa API-ja se ne hardkodira, nego se prosljedjuje pri pokretanju:
///   flutter run --dart-define=API_BASE_URL=http://localhost:5000
/// Windows desktop aplikacija se povezuje na localhost, jer se izvrsava
/// na istoj masini kao i server tokom pregleda rada.
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  static const Duration requestTimeout = Duration(seconds: 20);

  /// Interval osvjezavanja broja neprocitanih notifikacija.
  static const Duration notificationPollInterval = Duration(seconds: 30);

  /// Podrazumijevana velicina stranice na tabelarnim prikazima.
  static const int pageSize = 20;

  /// Puna adresa slike koja je na serveru spremljena kao relativna putanja.
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$apiBaseUrl$path';
  }
}
