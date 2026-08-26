import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_stripe/flutter_stripe.dart';

import '../models/payment.dart';

enum StripeCheckoutOutcome { success, cancelled, failed }

class StripeCheckoutResult {
  const StripeCheckoutResult(this.outcome, {this.message});

  final StripeCheckoutOutcome outcome;
  final String? message;
}

/// Prikazuje Stripe PaymentSheet unutar aplikacije za dato zapoceto placanje.
///
/// Namjerno postoji samo ovaj jedan put do placanja u aplikaciji - nema
/// preusmjeravanja na eksterni browser. Uspjeh ovdje znaci samo da je korisnik
/// unio validne podatke kartice; stvarna potvrda placanja i aktivacija karata
/// desava se tek kada Stripe pozove server-side webhook (PaymentService.HandleStripeWebhookAsync).
class StripeCheckout {
  const StripeCheckout._();

  static Future<StripeCheckoutResult> present(PaymentInitiation payment) async {
    if (!payment.requiresStripePayment) {
      // Nacin placanja nije online (npr. gotovina na licu mjesta) - nema sta da se prikaze,
      // narudzba ostaje "Ceka placanje" dok osoblje rucno ne evidentira uplatu.
      return const StripeCheckoutResult(StripeCheckoutOutcome.success);
    }

    try {
      Stripe.publishableKey = payment.stripePublishableKey!;
      await Stripe.instance.applySettings();

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: payment.stripeClientSecret!,
          merchantDisplayName: 'SkiPass',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return const StripeCheckoutResult(StripeCheckoutOutcome.success);
    } on StripeException catch (error) {
      final isCancelled = error.error.code == FailureCode.Canceled;
      return StripeCheckoutResult(
        isCancelled ? StripeCheckoutOutcome.cancelled : StripeCheckoutOutcome.failed,
        message: isCancelled ? null : (error.error.localizedMessage ?? error.error.message),
      );
    } catch (error) {
      return StripeCheckoutResult(StripeCheckoutOutcome.failed, message: error.toString());
    }
  }
}
