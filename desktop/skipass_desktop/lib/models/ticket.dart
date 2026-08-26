import '../core/utils/json.dart';

class TicketType {
  const TicketType({
    required this.id,
    required this.name,
    required this.pricePerDay,
    required this.maxDays,
    required this.discountPercentage,
    required this.isActive,
    required this.skiResortId,
    required this.skiResortName,
    this.description,
    this.minAge,
    this.maxAge,
  });

  final int id;
  final String name;
  final double pricePerDay;
  final int maxDays;
  final double discountPercentage;
  final bool isActive;
  final int skiResortId;
  final String skiResortName;
  final String? description;
  final int? minAge;
  final int? maxAge;

  /// Ista formula koju server koristi pri kreiranju narudzbe; sluzi samo za prikaz.
  double priceFor(int days) {
    final gross = pricePerDay * days;
    return double.parse((gross * (1 - discountPercentage / 100)).toStringAsFixed(2));
  }

  String get ageLabel {
    if (minAge != null && maxAge != null) return 'Uzrast $minAge - $maxAge god.';
    if (minAge != null) return 'Od $minAge god.';
    if (maxAge != null) return 'Do $maxAge god.';
    return 'Svi uzrasti';
  }

  factory TicketType.fromJson(Map<String, dynamic> json) => TicketType(
        id: Json.integer(json['id']),
        name: Json.str(json['name']),
        pricePerDay: Json.decimal(json['pricePerDay']),
        maxDays: Json.integer(json['maxDays'], 1),
        discountPercentage: Json.decimal(json['discountPercentage']),
        isActive: Json.boolean(json['isActive'], true),
        skiResortId: Json.integer(json['skiResortId']),
        skiResortName: Json.str(json['skiResortName']),
        description: Json.strOrNull(json['description']),
        minAge: Json.integerOrNull(json['minAge']),
        maxAge: Json.integerOrNull(json['maxAge']),
      );
}

class SkiPassTicket {
  const SkiPassTicket({
    required this.id,
    required this.qrCode,
    required this.holderFullName,
    required this.validFrom,
    required this.validTo,
    required this.numberOfDays,
    required this.price,
    required this.status,
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentMethodName,
    required this.ticketTypeName,
    required this.skiResortName,
    required this.validationCount,
    this.lastValidatedAt,
  });

  final int id;
  final String qrCode;
  final String holderFullName;
  final DateTime validFrom;
  final DateTime validTo;
  final int numberOfDays;
  final double price;
  final String status;
  final int orderId;
  final String orderNumber;
  final String orderStatus;
  final String paymentMethodName;
  final String ticketTypeName;
  final String skiResortName;
  final int validationCount;
  final DateTime? lastValidatedAt;

  bool get isUsable => status == 'Active' || status == 'Used';

  /// Karta vazi danas i moze se pokazati na ulazu na lift.
  bool get isValidToday {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    return isUsable && !day.isBefore(validFrom) && !day.isAfter(validTo);
  }

  factory SkiPassTicket.fromJson(Map<String, dynamic> json) => SkiPassTicket(
        id: Json.integer(json['id']),
        qrCode: Json.str(json['qrCode']),
        holderFullName: Json.str(json['holderFullName']),
        validFrom: Json.dateOnly(json['validFrom']),
        validTo: Json.dateOnly(json['validTo']),
        numberOfDays: Json.integer(json['numberOfDays'], 1),
        price: Json.decimal(json['price']),
        status: Json.str(json['status']),
        orderId: Json.integer(json['skiPassOrderId']),
        orderNumber: Json.str(json['orderNumber']),
        orderStatus: Json.str(json['orderStatus']),
        paymentMethodName: Json.str(json['paymentMethodName']),
        ticketTypeName: Json.str(json['ticketTypeName']),
        skiResortName: Json.str(json['skiResortName']),
        validationCount: Json.integer(json['validationCount']),
        lastValidatedAt: Json.dateOrNull(json['lastValidatedAt']),
      );
}
