import '../core/utils/json.dart';

class Trail {
  const Trail({
    required this.id,
    required this.name,
    required this.code,
    required this.lengthMeters,
    required this.verticalDropMeters,
    required this.isOpen,
    required this.hasNightSkiing,
    required this.hasSnowmaking,
    required this.crowdLevel,
    required this.skiResortId,
    required this.skiResortName,
    required this.difficultyName,
    required this.difficultyColorHex,
    required this.averageRating,
    required this.reviewCount,
    required this.openIncidentCount,
    this.description,
    this.imageUrl,
    this.latestSnowDepthCm,
    this.latestConditionNote,
    this.latestConditionRecordedAt,
  });

  final int id;
  final String name;
  final String code;
  final int lengthMeters;
  final int verticalDropMeters;
  final bool isOpen;
  final bool hasNightSkiing;
  final bool hasSnowmaking;
  final String crowdLevel;
  final int skiResortId;
  final String skiResortName;
  final String difficultyName;
  final String difficultyColorHex;
  final double averageRating;
  final int reviewCount;
  final int openIncidentCount;
  final String? description;
  final String? imageUrl;
  final int? latestSnowDepthCm;
  final String? latestConditionNote;
  final DateTime? latestConditionRecordedAt;

  /// Duzina staze prikazana u kilometrima, kako je navedeno u skici.
  String get lengthLabel => lengthMeters >= 1000
      ? '${(lengthMeters / 1000).toStringAsFixed(1)} km'
      : '$lengthMeters m';

  factory Trail.fromJson(Map<String, dynamic> json) => Trail(
        id: Json.integer(json['id']),
        name: Json.str(json['name']),
        code: Json.str(json['code']),
        lengthMeters: Json.integer(json['lengthMeters']),
        verticalDropMeters: Json.integer(json['verticalDropMeters']),
        isOpen: Json.boolean(json['isOpen']),
        hasNightSkiing: Json.boolean(json['hasNightSkiing']),
        hasSnowmaking: Json.boolean(json['hasSnowmaking']),
        crowdLevel: Json.str(json['estimatedCrowdLevel']),
        skiResortId: Json.integer(json['skiResortId']),
        skiResortName: Json.str(json['skiResortName']),
        difficultyName: Json.str(json['trailDifficultyName']),
        difficultyColorHex: Json.str(json['trailDifficultyColorHex']),
        averageRating: Json.decimal(json['averageRating']),
        reviewCount: Json.integer(json['reviewCount']),
        openIncidentCount: Json.integer(json['openIncidentCount']),
        description: Json.strOrNull(json['description']),
        imageUrl: Json.strOrNull(json['imageUrl']),
        latestSnowDepthCm: Json.integerOrNull(json['latestSnowDepthCm']),
        latestConditionNote: Json.strOrNull(json['latestConditionNote']),
        latestConditionRecordedAt: Json.dateOrNull(json['latestConditionRecordedAt']),
      );
}

class TrailConditionLog {
  const TrailConditionLog({
    required this.id,
    required this.recordedAt,
    required this.snowDepthCm,
    required this.conditionNote,
    required this.isTrailOpen,
    required this.trailName,
    required this.recordedByUserName,
  });

  final int id;
  final DateTime recordedAt;
  final int snowDepthCm;
  final String conditionNote;
  final bool isTrailOpen;
  final String trailName;
  final String recordedByUserName;

  factory TrailConditionLog.fromJson(Map<String, dynamic> json) => TrailConditionLog(
        id: Json.integer(json['id']),
        recordedAt: Json.date(json['recordedAt']),
        snowDepthCm: Json.integer(json['snowDepthCm']),
        conditionNote: Json.str(json['conditionNote']),
        isTrailOpen: Json.boolean(json['isTrailOpen']),
        trailName: Json.str(json['trailName']),
        recordedByUserName: Json.str(json['recordedByUserName']),
      );
}
