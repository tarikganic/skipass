import '../core/utils/json.dart';

class Benefit {
  const Benefit({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.effectivePrice,
    required this.isActive,
    required this.averageRating,
    required this.ratingCount,
    required this.categoryId,
    required this.categoryName,
    required this.skiResortName,
    required this.purchaseCount,
    this.imageUrl,
    this.brand,
    this.partnerName,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final double discountPercentage;
  final double effectivePrice;
  final bool isActive;
  final double averageRating;
  final int ratingCount;
  final int categoryId;
  final String categoryName;
  final String skiResortName;
  final int purchaseCount;
  final String? imageUrl;
  final String? brand;
  final String? partnerName;

  bool get hasDiscount => discountPercentage > 0;

  factory Benefit.fromJson(Map<String, dynamic> json) => Benefit(
        id: Json.integer(json['id']),
        name: Json.str(json['name']),
        description: Json.str(json['description']),
        price: Json.decimal(json['price']),
        discountPercentage: Json.decimal(json['discountPercentage']),
        effectivePrice: Json.decimal(json['effectivePrice']),
        isActive: Json.boolean(json['isActive'], true),
        averageRating: Json.decimal(json['averageRating']),
        ratingCount: Json.integer(json['ratingCount']),
        categoryId: Json.integer(json['benefitCategoryId']),
        categoryName: Json.str(json['benefitCategoryName']),
        skiResortName: Json.str(json['skiResortName']),
        purchaseCount: Json.integer(json['purchaseCount']),
        imageUrl: Json.strOrNull(json['imageUrl']),
        brand: Json.strOrNull(json['brand']),
        partnerName: Json.strOrNull(json['partnerName']),
      );
}

class BenefitPurchase {
  const BenefitPurchase({
    required this.id,
    required this.purchasedAt,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.benefitId,
    required this.benefitName,
    required this.categoryName,
    required this.allowedNextStatuses,
    this.benefitImageUrl,
    this.cancellationReason,
  });

  final int id;
  final DateTime purchasedAt;
  final int quantity;
  final double totalPrice;
  final String status;
  final int benefitId;
  final String benefitName;
  final String categoryName;
  final List<String> allowedNextStatuses;
  final String? benefitImageUrl;
  final String? cancellationReason;

  bool get canBeCancelled => allowedNextStatuses.contains('Cancelled');

  factory BenefitPurchase.fromJson(Map<String, dynamic> json) => BenefitPurchase(
        id: Json.integer(json['id']),
        purchasedAt: Json.date(json['purchasedAt']),
        quantity: Json.integer(json['quantity'], 1),
        totalPrice: Json.decimal(json['totalPrice']),
        status: Json.str(json['status']),
        benefitId: Json.integer(json['benefitId']),
        benefitName: Json.str(json['benefitName']),
        categoryName: Json.str(json['benefitCategoryName']),
        allowedNextStatuses: Json.strings(json['allowedNextStatuses']),
        benefitImageUrl: Json.strOrNull(json['benefitImageUrl']),
        cancellationReason: Json.strOrNull(json['cancellationReason']),
      );
}
