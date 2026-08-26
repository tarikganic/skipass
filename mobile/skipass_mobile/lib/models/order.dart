import '../core/utils/json.dart';
import 'ticket.dart';

class PaymentSummary {
  const PaymentSummary({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethodName,
    required this.refundedAmount,
    this.paidAt,
    this.refundedAt,
  });

  final int id;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethodName;
  final double refundedAmount;
  final DateTime? paidAt;
  final DateTime? refundedAt;

  factory PaymentSummary.fromJson(Map<String, dynamic> json) => PaymentSummary(
        id: Json.integer(json['id']),
        amount: Json.decimal(json['amount']),
        currency: Json.str(json['currency'], 'BAM'),
        status: Json.str(json['status']),
        paymentMethodName: Json.str(json['paymentMethodName']),
        refundedAmount: Json.decimal(json['refundedAmount']),
        paidAt: Json.dateOrNull(json['paidAt']),
        refundedAt: Json.dateOrNull(json['refundedAt']),
      );
}

class SkiPassOrder {
  const SkiPassOrder({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.userFullName,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.ticketCount,
    required this.isPaid,
    required this.paidAmount,
    required this.refundedAmount,
    required this.allowedNextStatuses,
    this.note,
    this.cancellationReason,
    this.confirmedAt,
    this.cancelledAt,
    this.tickets = const [],
    this.payments = const [],
  });

  final int id;
  final String orderNumber;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final String userFullName;
  final int paymentMethodId;
  final String paymentMethodName;
  final int ticketCount;
  final bool isPaid;
  final double paidAmount;
  final double refundedAmount;
  final List<String> allowedNextStatuses;
  final String? note;
  final String? cancellationReason;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final List<SkiPassTicket> tickets;
  final List<PaymentSummary> payments;

  /// Narudzba jos ceka uplatu, pa se korisniku nudi dugme za placanje.
  bool get awaitsPayment => !isPaid && status == 'Pending';

  bool get canBeCancelled => allowedNextStatuses.contains('Cancelled');

  factory SkiPassOrder.fromJson(Map<String, dynamic> json) => SkiPassOrder(
        id: Json.integer(json['id']),
        orderNumber: Json.str(json['orderNumber']),
        orderDate: Json.date(json['orderDate']),
        totalAmount: Json.decimal(json['totalAmount']),
        status: Json.str(json['status']),
        userFullName: Json.str(json['userFullName']),
        paymentMethodId: Json.integer(json['paymentMethodId']),
        paymentMethodName: Json.str(json['paymentMethodName']),
        ticketCount: Json.integer(json['ticketCount']),
        isPaid: Json.boolean(json['isPaid']),
        paidAmount: Json.decimal(json['paidAmount']),
        refundedAmount: Json.decimal(json['refundedAmount']),
        allowedNextStatuses: Json.strings(json['allowedNextStatuses']),
        note: Json.strOrNull(json['note']),
        cancellationReason: Json.strOrNull(json['cancellationReason']),
        confirmedAt: Json.dateOrNull(json['confirmedAt']),
        cancelledAt: Json.dateOrNull(json['cancelledAt']),
        tickets: Json.list(json['tickets'], SkiPassTicket.fromJson),
        payments: Json.list(json['payments'], PaymentSummary.fromJson),
      );
}

/// Jedna karta u korpi prije slanja narudzbe na server.
class OrderDraftItem {
  OrderDraftItem({
    required this.ticketType,
    required this.holderFirstName,
    required this.holderLastName,
    required this.validFrom,
    required this.numberOfDays,
  });

  final TicketType ticketType;
  String holderFirstName;
  String holderLastName;
  DateTime validFrom;
  int numberOfDays;

  double get price => ticketType.priceFor(numberOfDays);

  String get holderFullName => '$holderFirstName $holderLastName'.trim();

  Map<String, dynamic> toJson() => {
        'ticketTypeId': ticketType.id,
        'holderFirstName': holderFirstName,
        'holderLastName': holderLastName,
        'validFrom':
            '${validFrom.year.toString().padLeft(4, '0')}-${validFrom.month.toString().padLeft(2, '0')}-${validFrom.day.toString().padLeft(2, '0')}',
        'numberOfDays': numberOfDays,
      };
}
