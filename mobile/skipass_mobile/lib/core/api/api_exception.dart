/// Greska vracena sa servera, prevedena u oblik koji korisnicki interfejs moze prikazati.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
    this.traceId,
  });

  final String message;
  final int? statusCode;

  /// Validacijske poruke po polju; prikazuju se ispod odgovarajuce kontrole.
  final Map<String, List<String>> fieldErrors;
  final String? traceId;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidation => statusCode == 400 && fieldErrors.isNotEmpty;
  bool get isConflict => statusCode == 409;

  /// Poruka za polje, ako je server prijavio gresku bas za to polje.
  String? errorFor(String field) {
    for (final entry in fieldErrors.entries) {
      if (entry.key.toLowerCase() == field.toLowerCase() && entry.value.isNotEmpty) {
        return entry.value.first;
      }
    }
    return null;
  }

  @override
  String toString() => message;
}

/// Mreza nije dostupna ili je zahtjev istekao.
class NetworkException extends ApiException {
  NetworkException([String? message])
      : super(
          message: message ??
              'Nije moguce uspostaviti vezu sa serverom. Provjerite internet konekciju.',
        );
}
