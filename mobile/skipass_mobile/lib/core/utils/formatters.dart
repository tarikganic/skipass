import 'package:intl/intl.dart';

/// Formatiranje datuma, iznosa i mjernih jedinica na jednom mjestu,
/// kako bi isti podaci svuda izgledali isto.
class Formatters {
  const Formatters._();

  static final DateFormat _date = DateFormat('dd.MM.yyyy');
  static final DateFormat _dateTime = DateFormat('dd.MM.yyyy. HH:mm');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _dayMonth = DateFormat('dd.MM.');
  static final NumberFormat _money = NumberFormat('#,##0.00', 'bs');

  static String date(DateTime value) => _date.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value);

  static String time(DateTime value) => _time.format(value);

  static String dayMonth(DateTime value) => _dayMonth.format(value);

  /// Iznos sa valutom, npr. "113,40 KM".
  static String money(double value) => '${_money.format(value)} KM';

  static String temperature(double celsius) => '${celsius.toStringAsFixed(1)} °C';

  static String distanceMeters(int meters) =>
      meters >= 1000 ? '${(meters / 1000).toStringAsFixed(1)} km' : '$meters m';

  /// Raspon vazenja karte; za jednodnevnu kartu prikazuje se samo jedan datum.
  static String dateRange(DateTime from, DateTime to) =>
      from == to ? date(from) : '${date(from)} - ${date(to)}';

  /// Relativno vrijeme za liste obavijesti i notifikacija.
  static String relative(DateTime value) {
    final difference = DateTime.now().difference(value);

    if (difference.isNegative) return date(value);
    if (difference.inMinutes < 1) return 'upravo sada';
    if (difference.inMinutes < 60) return 'prije ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'prije ${difference.inHours} h';
    if (difference.inDays == 1) return 'juce';
    if (difference.inDays < 7) return 'prije ${difference.inDays} dana';

    return date(value);
  }

  /// Broj dana u ispravnom padezu.
  static String days(int count) {
    if (count == 1) return '1 dan';
    if (count >= 2 && count <= 4) return '$count dana';
    return '$count dana';
  }

  /// Broj karata u ispravnom padezu.
  static String tickets(int count) {
    if (count == 1) return '1 karta';
    if (count >= 2 && count <= 4) return '$count karte';
    return '$count karata';
  }
}
