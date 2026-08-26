import '../core/utils/json.dart';

class WeatherLog {
  const WeatherLog({
    required this.id,
    required this.recordedAt,
    required this.temperatureCelsius,
    required this.windSpeedKmh,
    required this.snowfallCm,
    required this.snowDepthCm,
    required this.conditions,
    required this.visibilityMeters,
  });

  final int id;
  final DateTime recordedAt;
  final double temperatureCelsius;
  final double windSpeedKmh;
  final double snowfallCm;
  final int snowDepthCm;
  final String conditions;
  final int visibilityMeters;

  factory WeatherLog.fromJson(Map<String, dynamic> json) => WeatherLog(
        id: Json.integer(json['id']),
        recordedAt: Json.date(json['recordedAt']),
        temperatureCelsius: Json.decimal(json['temperatureCelsius']),
        windSpeedKmh: Json.decimal(json['windSpeedKmh']),
        snowfallCm: Json.decimal(json['snowfallCm']),
        snowDepthCm: Json.integer(json['snowDepthCm']),
        conditions: Json.str(json['conditions']),
        visibilityMeters: Json.integer(json['visibilityMeters']),
      );
}
