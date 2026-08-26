import '../core/utils/json.dart';

class SkiResort {
  const SkiResort({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.baseAltitudeMeters,
    required this.peakAltitudeMeters,
    required this.openingTime,
    required this.closingTime,
    required this.isActive,
    required this.cityId,
    required this.cityName,
    required this.trailCount,
    required this.openTrailCount,
    required this.skiLiftCount,
    required this.operationalLiftCount,
    this.logoUrl,
    this.contactEmail,
    this.contactPhone,
  });

  final int id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final int baseAltitudeMeters;
  final int peakAltitudeMeters;
  final String openingTime;
  final String closingTime;
  final bool isActive;
  final int cityId;
  final String cityName;
  final int trailCount;
  final int openTrailCount;
  final int skiLiftCount;
  final int operationalLiftCount;
  final String? logoUrl;
  final String? contactEmail;
  final String? contactPhone;

  factory SkiResort.fromJson(Map<String, dynamic> json) => SkiResort(
        id: Json.integer(json['id']),
        name: Json.str(json['name']),
        description: Json.str(json['description']),
        latitude: Json.decimal(json['latitude']),
        longitude: Json.decimal(json['longitude']),
        baseAltitudeMeters: Json.integer(json['baseAltitudeMeters']),
        peakAltitudeMeters: Json.integer(json['peakAltitudeMeters']),
        openingTime: Json.time(json['openingTime']),
        closingTime: Json.time(json['closingTime']),
        isActive: Json.boolean(json['isActive'], true),
        cityId: Json.integer(json['cityId']),
        cityName: Json.str(json['cityName']),
        trailCount: Json.integer(json['trailCount']),
        openTrailCount: Json.integer(json['openTrailCount']),
        skiLiftCount: Json.integer(json['skiLiftCount']),
        operationalLiftCount: Json.integer(json['operationalLiftCount']),
        logoUrl: Json.strOrNull(json['logoUrl']),
        contactEmail: Json.strOrNull(json['contactEmail']),
        contactPhone: Json.strOrNull(json['contactPhone']),
      );
}
