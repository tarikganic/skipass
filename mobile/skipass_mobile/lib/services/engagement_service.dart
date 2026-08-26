import 'dart:io';

import '../core/api/api_client.dart';
import '../core/config/app_config.dart';
import '../models/announcement.dart';
import '../models/incident.dart';
import '../models/paged_result.dart';

/// Prijave incidenata, notifikacije i ocjene - sve sto korisnik salje ka skijalistu.
class EngagementService {
  EngagementService(this._api);

  final ApiClient _api;

  // --- Incidenti ---

  Future<PagedResult<Incident>> searchIncidents({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    String? status,
    int? incidentTypeId,
  }) async {
    final json = await _api.get('/api/Incidents', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'status': status,
      'incidentTypeId': incidentTypeId,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, Incident.fromJson);
  }

  Future<Incident> reportIncident({
    required int incidentTypeId,
    required String description,
    required double latitude,
    required double longitude,
    int? trailId,
    int? skiLiftId,
    String? imageUrl,
  }) async {
    final json = await _api.post('/api/Incidents', body: {
      'incidentTypeId': incidentTypeId,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'trailId': trailId,
      'skiLiftId': skiLiftId,
      'imageUrl': imageUrl,
    });
    return Incident.fromJson(json as Map<String, dynamic>);
  }

  Future<String> uploadIncidentImage(File file) async {
    final json = await _api.uploadFile('/api/Files/images/incidents', file);
    return (json as Map<String, dynamic>)['url'] as String;
  }

  // --- Notifikacije ---

  Future<PagedResult<AppNotification>> searchNotifications({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    bool? isRead,
  }) async {
    final json = await _api.get('/api/Notifications', query: {
      'page': page,
      'pageSize': pageSize,
      'isRead': isRead,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, AppNotification.fromJson);
  }

  Future<int> unreadNotificationCount() async {
    final json = await _api.get('/api/Notifications/unread-count');
    if (json is Map<String, dynamic>) {
      final value = json['unreadCount'];
      return value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  Future<void> markNotificationRead(int id) async {
    await _api.patch('/api/Notifications/$id/read');
  }

  Future<int> markAllNotificationsRead() async {
    final json = await _api.patch('/api/Notifications/read-all');
    if (json is Map<String, dynamic>) {
      final value = json['count'];
      return value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  // --- Ocjene ---

  Future<PagedResult<Review>> searchReviews({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    int? trailId,
    int? benefitId,
    int? skiResortId,
    int? userId,
  }) async {
    final json = await _api.get('/api/Reviews', query: {
      'page': page,
      'pageSize': pageSize,
      'trailId': trailId,
      'benefitId': benefitId,
      'skiResortId': skiResortId,
      'userId': userId,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, Review.fromJson);
  }

  Future<Review> createReview({
    required String targetType,
    required int rating,
    String? comment,
    int? trailId,
    int? benefitId,
    int? skiResortId,
  }) async {
    final json = await _api.post('/api/Reviews', body: {
      'targetType': targetType,
      'rating': rating,
      'comment': comment,
      'trailId': trailId,
      'benefitId': benefitId,
      'skiResortId': skiResortId,
    });
    return Review.fromJson(json as Map<String, dynamic>);
  }

  Future<Review> updateReview(int id, int rating, String? comment) async {
    final json = await _api.put('/api/Reviews/$id', body: {
      'rating': rating,
      'comment': comment,
    });
    return Review.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteReview(int id) async {
    await _api.delete('/api/Reviews/$id');
  }
}
