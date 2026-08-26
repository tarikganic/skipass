/// Sigurno citanje vrijednosti iz JSON mape.
///
/// API vraca dobro definisane tipove, ali ovi pomocnici sprjecavaju pad aplikacije
/// ako neko polje izostane ili stigne kao drugi numericki tip.
class Json {
  const Json._();

  static String str(dynamic value, [String fallback = '']) =>
      value == null ? fallback : value.toString();

  static String? strOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static int integer(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? integerOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double decimal(dynamic value, [double fallback = 0]) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool boolean(dynamic value, [bool fallback = false]) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  static DateTime date(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '')?.toLocal() ?? DateTime.now();

  static DateTime? dateOrNull(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  /// Cita polje tipa DateOnly (npr. "2026-02-14") bez pretvaranja u lokalnu zonu.
  static DateTime dateOnly(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();

  /// Cita polje tipa TimeOnly (npr. "08:30:00").
  static String time(dynamic value) {
    final text = value?.toString() ?? '';
    final parts = text.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return text;
  }

  static List<T> list<T>(dynamic value, T Function(Map<String, dynamic>) mapper) {
    if (value is! List) return <T>[];
    return value
        .whereType<Map<String, dynamic>>()
        .map(mapper)
        .toList(growable: false);
  }

  static List<String> strings(dynamic value) {
    if (value is! List) return const <String>[];
    return value.map((e) => e.toString()).toList(growable: false);
  }
}
