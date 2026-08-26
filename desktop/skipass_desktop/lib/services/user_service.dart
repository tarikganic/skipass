import '../core/api/api_client.dart';
import '../core/config/app_config.dart';
import '../models/paged_result.dart';
import '../models/user.dart';

/// Upravljanje korisnicima - dostupno samo administratoru.
class UserService {
  UserService(this._api);

  final ApiClient _api;

  Future<PagedResult<AppUser>> search({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    String? role,
    bool? isActive,
  }) async {
    final json = await _api.get('/api/Users', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'role': role,
      'isActive': isActive,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, AppUser.fromJson);
  }

  Future<AppUser> getById(int id) async {
    final json = await _api.get('/api/Users/$id');
    return AppUser.fromJson(json as Map<String, dynamic>);
  }

  Future<AppUser> create(Map<String, dynamic> body) async {
    final json = await _api.post('/api/Users', body: body);
    return AppUser.fromJson(json as Map<String, dynamic>);
  }

  Future<AppUser> update(int id, Map<String, dynamic> body) async {
    final json = await _api.put('/api/Users/$id', body: body);
    return AppUser.fromJson(json as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/Users/$id');
  }
}
