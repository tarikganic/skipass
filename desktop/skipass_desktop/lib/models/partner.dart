import '../core/utils/json.dart';

class Partner {
  const Partner({
    required this.id,
    required this.name,
    required this.isActive,
    required this.benefitCount,
    this.description,
    this.contactEmail,
    this.contactPhone,
    this.website,
    this.logoUrl,
    this.address,
    this.cityId,
    this.cityName,
  });

  final int id;
  final String name;
  final bool isActive;
  final int benefitCount;
  final String? description;
  final String? contactEmail;
  final String? contactPhone;
  final String? website;
  final String? logoUrl;
  final String? address;
  final int? cityId;
  final String? cityName;

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
        id: Json.integer(json['id']),
        name: Json.str(json['name']),
        isActive: Json.boolean(json['isActive'], true),
        benefitCount: Json.integer(json['benefitCount']),
        description: Json.strOrNull(json['description']),
        contactEmail: Json.strOrNull(json['contactEmail']),
        contactPhone: Json.strOrNull(json['contactPhone']),
        website: Json.strOrNull(json['website']),
        logoUrl: Json.strOrNull(json['logoUrl']),
        address: Json.strOrNull(json['address']),
        cityId: Json.integerOrNull(json['cityId']),
        cityName: Json.strOrNull(json['cityName']),
      );
}
