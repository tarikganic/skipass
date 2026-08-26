import 'dart:io';

import '../core/api/api_client.dart';
import '../core/config/app_config.dart';
import '../models/announcement.dart';
import '../models/incident.dart';
import '../models/paged_result.dart';

/// Incidenti, obavijesti i notifikacije - administracija komunikacije sa skijasima.
class EngagementService {
  EngagementService(this._api);

  final ApiClient _api;

  // --- Incidenti ---

  Future<PagedResult<Incident>> searchIncidents({
    int page = 1,
    int pageSize = 100,
    String? query,
    String? status,
  }) async {
    final json = await _api.get('/api/Incidents', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'status': status,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, Incident.fromJson);
  }

  Future<Incident> createIncident(Map<String, dynamic> body) async {
    final json = await _api.post('/api/Incidents', body: body);
    return Incident.fromJson(json as Map<String, dynamic>);
  }

  Future<Incident> updateIncidentStatus(int id, String status, String? resolutionNote) async {
    final json = await _api.patch('/api/Incidents/$id/status', body: {
      'status': status,
      'resolutionNote': resolutionNote,
    });
    return Incident.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteIncident(int id) async {
    await _api.delete('/api/Incidents/$id');
  }

  // --- Obavijesti ---

  Future<PagedResult<Announcement>> searchAnnouncements({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    int? categoryId,
    bool? isUrgent,
  }) async {
    final json = await _api.get('/api/Announcements', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'announcementCategoryId': categoryId,
      'isUrgent': isUrgent,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, Announcement.fromJson);
  }

  Future<Announcement> createAnnouncement(Map<String, dynamic> body) async {
    final json = await _api.post('/api/Announcements', body: body);
    return Announcement.fromJson(json as Map<String, dynamic>);
  }

  Future<Announcement> updateAnnouncement(int id, Map<String, dynamic> body) async {
    final json = await _api.put('/api/Announcements/$id', body: body);
    return Announcement.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteAnnouncement(int id) async {
    await _api.delete('/api/Announcements/$id');
  }

  Future<String> uploadImage(String category, File file) async {
    final json = await _api.uploadFile('/api/Files/images/$category', file);
    return (json as Map<String, dynamic>)['url'] as String;
  }

  // --- Notifikacije ---

  Future<PagedResult<AppNotification>> searchNotifications({int page = 1, int pageSize = AppConfig.pageSize}) async {
    final json = await _api.get('/api/Notifications', query: {'page': page, 'pageSize': pageSize});
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

  Future<void> markAllNotificationsRead() async {
    await _api.patch('/api/Notifications/read-all');
  }

  Future<void> sendNotification({required int userId, required String title, required String message, String? targetRoute}) async {
    await _api.post('/api/Notifications', body: {
      'userId': userId,
      'title': title,
      'message': message,
      'targetRoute': targetRoute,
    });
  }
}
