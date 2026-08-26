import '../core/utils/json.dart';

/// Odgovor na zapocinjanje placanja (POST /api/Payments). Kada je nacin placanja
/// online, server otvara Stripe PaymentIntent i vraca podatke potrebne da mobilna
/// aplikacija prikaze Stripe PaymentSheet unutar aplikacije - placanje se nikad
/// ne finalizira na klijentu, samo na serveru preko Stripe webhook-a.
class PaymentInitiation {
  const PaymentInitiation({
    required this.id,
    required this.status,
    this.stripeClientSecret,
    this.stripePublishableKey,
  });

  final int id;
  final String status;
  final String? stripeClientSecret;
  final String? stripePublishableKey;

  /// Nacin placanja je online (Stripe) - treba prikazati PaymentSheet.
  bool get requiresStripePayment => stripeClientSecret != null && stripePublishableKey != null;

  factory PaymentInitiation.fromJson(Map<String, dynamic> json) => PaymentInitiation(
        id: Json.integer(json['id']),
        status: Json.str(json['status']),
        stripeClientSecret: Json.strOrNull(json['stripeClientSecret']),
        stripePublishableKey: Json.strOrNull(json['stripePublishableKey']),
      );
}
