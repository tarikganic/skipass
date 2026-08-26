import '../core/utils/json.dart';

class Incident {
  const Incident({
    required this.id,
    required this.reportedAt,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.isUrgent,
    required this.reportedByUserName,
    required this.incidentTypeName,
    required this.allowedNextStatuses,
    this.imageUrl,
    this.resolutionNote,
    this.handledAt,
    this.handledByUserName,
    this.trailName,
    this.skiLiftName,
  });

  final int id;
  final DateTime reportedAt;
  final String description;
  final double latitude;
  final double longitude;
  final String status;
  final bool isUrgent;
  final String reportedByUserName;
  final String incidentTypeName;
  final List<String> allowedNextStatuses;
  final String? imageUrl;
  final String? resolutionNote;
  final DateTime? handledAt;
  final String? handledByUserName;
  final String? trailName;
  final String? skiLiftName;

  /// Lokacija na koju se prijava odnosi, u obliku pogodnom za prikaz.
  String get locationLabel => trailName ?? skiLiftName ?? 'Skijaliste';

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
        id: Json.integer(json['id']),
        reportedAt: Json.date(json['reportedAt']),
        description: Json.str(json['description']),
        latitude: Json.decimal(json['latitude']),
        longitude: Json.decimal(json['longitude']),
        status: Json.str(json['status']),
        isUrgent: Json.boolean(json['isUrgent']),
        reportedByUserName: Json.str(json['reportedByUserName']),
        incidentTypeName: Json.str(json['incidentTypeName']),
        allowedNextStatuses: Json.strings(json['allowedNextStatuses']),
        imageUrl: Json.strOrNull(json['imageUrl']),
        resolutionNote: Json.strOrNull(json['resolutionNote']),
        handledAt: Json.dateOrNull(json['handledAt']),
        handledByUserName: Json.strOrNull(json['handledByUserName']),
        trailName: Json.strOrNull(json['trailName']),
        skiLiftName: Json.strOrNull(json['skiLiftName']),
      );
}
