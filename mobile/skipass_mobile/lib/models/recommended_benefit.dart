import '../core/utils/json.dart';

class RecommendationReasonCodes {
  static const purchasedCategory = 'PurchasedCategory';
  static const viewedCategory = 'ViewedCategory';
  static const usedPartner = 'UsedPartner';
  static const preferredBrand = 'PreferredBrand';
  static const popularFallback = 'PopularFallback';
}

class RecommendationReason {
  const RecommendationReason({
    required this.code,
    this.categoryName,
    this.partnerName,
    this.brand,
  });

  final String code;
  final String? categoryName;
  final String? partnerName;
  final String? brand;

  factory RecommendationReason.fromJson(Map<String, dynamic> json) => RecommendationReason(
        code: Json.str(json['code']),
        categoryName: Json.strOrNull(json['categoryName']),
        partnerName: Json.strOrNull(json['partnerName']),
        brand: Json.strOrNull(json['brand']),
      );
}

class RecommendedBenefit {
  const RecommendedBenefit({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.effectivePrice,
    required this.averageRating,
    required this.ratingCount,
    required this.categoryId,
    required this.categoryName,
    required this.skiResortName,
    required this.reasons,
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
  final double averageRating;
  final int ratingCount;
  final int categoryId;
  final String categoryName;
  final String skiResortName;
  final List<RecommendationReason> reasons;
  final String? imageUrl;
  final String? brand;
  final String? partnerName;

  bool get hasDiscount => discountPercentage > 0;

  factory RecommendedBenefit.fromJson(Map<String, dynamic> json) => RecommendedBenefit(
        id: Json.integer(json['id']),
        name: Json.str(json['name']),
        description: Json.str(json['description']),
        price: Json.decimal(json['price']),
        discountPercentage: Json.decimal(json['discountPercentage']),
        effectivePrice: Json.decimal(json['effectivePrice']),
        averageRating: Json.decimal(json['averageRating']),
        ratingCount: Json.integer(json['ratingCount']),
        categoryId: Json.integer(json['benefitCategoryId']),
        categoryName: Json.str(json['benefitCategoryName']),
        skiResortName: Json.str(json['skiResortName']),
        reasons: (json['reasons'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(RecommendationReason.fromJson)
            .toList(growable: false),
        imageUrl: Json.strOrNull(json['imageUrl']),
        brand: Json.strOrNull(json['brand']),
        partnerName: Json.strOrNull(json['partnerName']),
      );
}
