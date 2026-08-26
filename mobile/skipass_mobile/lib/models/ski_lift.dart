import '../core/utils/json.dart';

class SkiLift {
  const SkiLift({
    required this.id,
    required this.name,
    required this.code,
    required this.lengthMeters,
    required this.capacityPerHour,
    required this.rideDurationMinutes,
    required this.isOperational,
    required this.currentRiders,
    required this.skiResortId,
    required this.skiResortName,
    required this.liftTypeName,
    required this.openMaintenanceCount,
    this.description,
    this.lastMaintenanceAt,
  });

  final int id;
  final String name;
  final String code;
  final int lengthMeters;
  final int capacityPerHour;
  final int rideDurationMinutes;
  final bool isOperational;
  final int currentRiders;
  final int skiResortId;
  final String skiResortName;
  final String liftTypeName;
  final int openMaintenanceCount;
  final String? description;
  final DateTime? lastMaintenanceAt;

  /// Procijenjena popunjenost lifta u odnosu na satni kapacitet.
  double get occupancyRatio =>
      capacityPerHour <= 0 ? 0 : (currentRiders / capacityPerHour).clamp(0, 1).toDouble();

  factory SkiLift.fromJson(Map<String, dynamic> json) => SkiLift(
        id: Json.integer(json['id']),
        name: Json.str(json['name']),
        code: Json.str(json['code']),
        lengthMeters: Json.integer(json['lengthMeters']),
        capacityPerHour: Json.integer(json['capacityPerHour']),
        rideDurationMinutes: Json.integer(json['rideDurationMinutes']),
        isOperational: Json.boolean(json['isOperational']),
        currentRiders: Json.integer(json['currentRiders']),
        skiResortId: Json.integer(json['skiResortId']),
        skiResortName: Json.str(json['skiResortName']),
        liftTypeName: Json.str(json['liftTypeName']),
        openMaintenanceCount: Json.integer(json['openMaintenanceCount']),
        description: Json.strOrNull(json['description']),
        lastMaintenanceAt: Json.dateOrNull(json['lastMaintenanceAt']),
      );
}
