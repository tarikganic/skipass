import '../core/utils/json.dart';

/// Jedan zapis u referentnoj tabeli (drzava, grad, tezina staze, tip lifta...).
///
/// Referentne tabele dijele isti oblik - naziv, opis i broj povezanih zapisa -
/// uz nekoliko polja koja postoje samo kod pojedinih tabela (ISO oznaka, boja,
/// redoslijed, itd). Umjesto deset gotovo identicnih klasa, jedan model pokriva
/// sve tabele, a `ReferenceTableConfig` (u services/reference_data_service.dart)
/// opisuje koja polja svaka konkretna tabela stvarno koristi.
class ReferenceItem {
  const ReferenceItem({
    required this.id,
    required this.name,
    this.description,
    this.isoCode,
    this.postalCode,
    this.colorHex,
    this.sortOrder,
    this.iconName,
    this.code,
    this.isUrgentByDefault,
    this.isOnline,
    this.isActive,
    this.countryId,
    this.countryName,
    this.relatedCount,
  });

  final int id;
  final String name;
  final String? description;

  // Country
  final String? isoCode;

  // City
  final String? postalCode;

  // TrailDifficulty
  final String? colorHex;
  final int? sortOrder;

  // BenefitCategory
  final String? iconName;

  // LiftType nema dodatna polja; IncidentType koristi isUrgentByDefault;
  // PaymentMethod koristi code/isOnline/isActive.
  final String? code;
  final bool? isUrgentByDefault;
  final bool? isOnline;
  final bool? isActive;

  // City
  final int? countryId;
  final String? countryName;

  /// Broj povezanih zapisa (npr. broj gradova za drzavu) - prikazuje se u listi
  /// i sprjecava brisanje kada je veci od nule.
  final int? relatedCount;

  factory ReferenceItem.fromJson(Map<String, dynamic> json) => ReferenceItem(
        id: Json.integer(json['id']),
        name: Json.str(json['name']),
        description: Json.strOrNull(json['description']),
        isoCode: Json.strOrNull(json['isoCode']),
        postalCode: Json.strOrNull(json['postalCode']),
        colorHex: Json.strOrNull(json['colorHex']),
        sortOrder: Json.integerOrNull(json['sortOrder']),
        iconName: Json.strOrNull(json['iconName']),
        code: Json.strOrNull(json['code']),
        isUrgentByDefault: json.containsKey('isUrgentByDefault')
            ? Json.boolean(json['isUrgentByDefault'])
            : null,
        isOnline: json.containsKey('isOnline') ? Json.boolean(json['isOnline']) : null,
        isActive: json.containsKey('isActive') ? Json.boolean(json['isActive']) : null,
        countryId: Json.integerOrNull(json['countryId']),
        countryName: Json.strOrNull(json['countryName']),
        relatedCount: Json.integerOrNull(json['cityCount']) ??
            Json.integerOrNull(json['trailCount']) ??
            Json.integerOrNull(json['skiLiftCount']) ??
            Json.integerOrNull(json['incidentCount']) ??
            Json.integerOrNull(json['benefitCount']) ??
            Json.integerOrNull(json['announcementCount']) ??
            Json.integerOrNull(json['orderCount']),
      );
}
