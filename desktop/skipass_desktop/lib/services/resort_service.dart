import 'dart:io';

import '../core/api/api_client.dart';
import '../core/config/app_config.dart';
import '../models/paged_result.dart';
import '../models/ski_lift.dart';
import '../models/ski_resort.dart';
import '../models/trail.dart';
import '../models/weather.dart';

/// Upravljanje skijalistima, stazama i ski liftovima.
class ResortService {
  ResortService(this._api);

  final ApiClient _api;

  // --- Skijalista ---

  Future<PagedResult<SkiResort>> searchResorts({int page = 1, int pageSize = AppConfig.pageSize, String? query}) async {
    final json = await _api.get('/api/SkiResorts', query: {'page': page, 'pageSize': pageSize, 'query': query});
    return PagedResult.fromJson(json as Map<String, dynamic>, SkiResort.fromJson);
  }

  // --- Staze ---

  Future<PagedResult<Trail>> searchTrails({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    int? difficultyId,
    bool? isOpen,
  }) async {
    final json = await _api.get('/api/Trails', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'trailDifficultyId': difficultyId,
      'isOpen': isOpen,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, Trail.fromJson);
  }

  Future<Trail> getTrail(int id) async {
    final json = await _api.get('/api/Trails/$id');
    return Trail.fromJson(json as Map<String, dynamic>);
  }

  Future<Trail> createTrail(Map<String, dynamic> body) async {
    final json = await _api.post('/api/Trails', body: body);
    return Trail.fromJson(json as Map<String, dynamic>);
  }

  Future<Trail> updateTrail(int id, Map<String, dynamic> body) async {
    final json = await _api.put('/api/Trails/$id', body: body);
    return Trail.fromJson(json as Map<String, dynamic>);
  }

  Future<Trail> updateTrailStatus(int id, {required bool isOpen, required String crowdLevel}) async {
    final json = await _api.patch('/api/Trails/$id/status', body: {
      'isOpen': isOpen,
      'estimatedCrowdLevel': crowdLevel,
    });
    return Trail.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteTrail(int id) async {
    await _api.delete('/api/Trails/$id');
  }

  Future<PagedResult<TrailConditionLog>> searchTrailConditions(int trailId, {int page = 1, int pageSize = 10}) async {
    final json = await _api.get('/api/Trails/$trailId/conditions', query: {'page': page, 'pageSize': pageSize});
    return PagedResult.fromJson(json as Map<String, dynamic>, TrailConditionLog.fromJson);
  }

  Future<TrailConditionLog> addTrailCondition(Map<String, dynamic> body) async {
    final json = await _api.post('/api/trail-conditions', body: body);
    return TrailConditionLog.fromJson(json as Map<String, dynamic>);
  }

  // --- Ski liftovi ---

  Future<PagedResult<SkiLift>> searchLifts({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    bool? isOperational,
  }) async {
    final json = await _api.get('/api/SkiLifts', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'isOperational': isOperational,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, SkiLift.fromJson);
  }

  Future<SkiLift> getLift(int id) async {
    final json = await _api.get('/api/SkiLifts/$id');
    return SkiLift.fromJson(json as Map<String, dynamic>);
  }

  Future<SkiLift> createLift(Map<String, dynamic> body) async {
    final json = await _api.post('/api/SkiLifts', body: body);
    return SkiLift.fromJson(json as Map<String, dynamic>);
  }

  Future<SkiLift> updateLift(int id, Map<String, dynamic> body) async {
    final json = await _api.put('/api/SkiLifts/$id', body: body);
    return SkiLift.fromJson(json as Map<String, dynamic>);
  }

  Future<SkiLift> updateLiftStatus(int id, bool isOperational) async {
    final json = await _api.patch('/api/SkiLifts/$id/status', body: {'isOperational': isOperational});
    return SkiLift.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteLift(int id) async {
    await _api.delete('/api/SkiLifts/$id');
  }

  Future<PagedResult<LiftMaintenanceRecord>> searchMaintenance({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    int? skiLiftId,
    String? status,
  }) async {
    final json = await _api.get('/api/lift-maintenance', query: {
      'page': page,
      'pageSize': pageSize,
      'skiLiftId': skiLiftId,
      'status': status,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, LiftMaintenanceRecord.fromJson);
  }

  Future<LiftMaintenanceRecord> reportMaintenance(Map<String, dynamic> body) async {
    final json = await _api.post('/api/lift-maintenance', body: body);
    return LiftMaintenanceRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<LiftMaintenanceRecord> updateMaintenanceStatus(int id, String status, String? resolutionNote) async {
    final json = await _api.patch('/api/lift-maintenance/$id/status', body: {
      'status': status,
      'resolutionNote': resolutionNote,
    });
    return LiftMaintenanceRecord.fromJson(json as Map<String, dynamic>);
  }

  // --- Vrijeme ---

  Future<WeatherLog?> getLatestWeather(int skiResortId) async {
    final json = await _api.get('/api/SkiResorts/$skiResortId/weather/latest');
    return json is Map<String, dynamic> ? WeatherLog.fromJson(json) : null;
  }

  Future<WeatherLog> addWeatherLog(Map<String, dynamic> body) async {
    final json = await _api.post('/api/weather-logs', body: body);
    return WeatherLog.fromJson(json as Map<String, dynamic>);
  }

  // --- Slike ---

  Future<String> uploadImage(String category, File file) async {
    final json = await _api.uploadFile('/api/Files/images/$category', file);
    return (json as Map<String, dynamic>)['url'] as String;
  }
}
