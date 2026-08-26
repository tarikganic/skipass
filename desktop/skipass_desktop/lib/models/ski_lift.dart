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

class LiftMaintenanceRecord {
  const LiftMaintenanceRecord({
    required this.id,
    required this.reportedAt,
    required this.description,
    required this.status,
    required this.requiresShutdown,
    required this.skiLiftId,
    required this.skiLiftName,
    required this.reportedByUserId,
    required this.reportedByUserName,
    required this.allowedNextStatuses,
    this.resolvedAt,
    this.resolutionNote,
    this.resolvedByUserName,
  });

  final int id;
  final DateTime reportedAt;
  final String description;
  final String status;
  final bool requiresShutdown;
  final int skiLiftId;
  final String skiLiftName;
  final int reportedByUserId;
  final String reportedByUserName;
  final List<String> allowedNextStatuses;
  final DateTime? resolvedAt;
  final String? resolutionNote;
  final String? resolvedByUserName;

  factory LiftMaintenanceRecord.fromJson(Map<String, dynamic> json) => LiftMaintenanceRecord(
        id: Json.integer(json['id']),
        reportedAt: Json.date(json['reportedAt']),
        description: Json.str(json['description']),
        status: Json.str(json['status']),
        requiresShutdown: Json.boolean(json['requiresShutdown']),
        skiLiftId: Json.integer(json['skiLiftId']),
        skiLiftName: Json.str(json['skiLiftName']),
        reportedByUserId: Json.integer(json['reportedByUserId']),
        reportedByUserName: Json.str(json['reportedByUserName']),
        allowedNextStatuses: Json.strings(json['allowedNextStatuses']),
        resolvedAt: Json.dateOrNull(json['resolvedAt']),
        resolutionNote: Json.strOrNull(json['resolutionNote']),
        resolvedByUserName: Json.strOrNull(json['resolvedByUserName']),
      );
}
