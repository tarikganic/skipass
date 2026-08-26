import '../core/api/api_client.dart';
import '../core/config/app_config.dart';
import '../models/announcement.dart';
import '../models/benefit.dart';
import '../models/home_summary.dart';
import '../models/paged_result.dart';
import '../models/recommended_benefit.dart';
import '../models/ski_lift.dart';
import '../models/ticket.dart';
import '../models/trail.dart';
import '../models/weather.dart';

/// Pristup podacima o skijalistu: pocetna, staze, liftovi, tipovi karata i obavijesti.
class CatalogService {
  CatalogService(this._api);

  final ApiClient _api;

  Future<HomeSummary> getHomeSummary({int? skiResortId}) async {
    final json = await _api.get('/api/Home/summary', query: {'skiResortId': skiResortId});
    return HomeSummary.fromJson(json as Map<String, dynamic>);
  }

  Future<PagedResult<Trail>> searchTrails({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    int? difficultyId,
    bool? isOpen,
    int? skiResortId,
    String? sortBy,
    bool sortDescending = false,
  }) async {
    final json = await _api.get('/api/Trails', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'trailDifficultyId': difficultyId,
      'isOpen': isOpen,
      'skiResortId': skiResortId,
      'sortBy': sortBy,
      'sortDescending': sortDescending,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, Trail.fromJson);
  }

  Future<Trail> getTrail(int id) async {
    final json = await _api.get('/api/Trails/$id');
    return Trail.fromJson(json as Map<String, dynamic>);
  }

  Future<PagedResult<TrailConditionLog>> getTrailConditions(
    int trailId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final json = await _api.get('/api/Trails/$trailId/conditions', query: {
      'page': page,
      'pageSize': pageSize,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, TrailConditionLog.fromJson);
  }

  Future<PagedResult<SkiLift>> searchLifts({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    bool? isOperational,
    int? skiResortId,
  }) async {
    final json = await _api.get('/api/SkiLifts', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'isOperational': isOperational,
      'skiResortId': skiResortId,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, SkiLift.fromJson);
  }

  Future<PagedResult<TicketType>> searchTicketTypes({
    int page = 1,
    int pageSize = 50,
    String? query,
    int? skiResortId,
  }) async {
    final json = await _api.get('/api/ticket-types', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'skiResortId': skiResortId,
      'isActive': true,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, TicketType.fromJson);
  }

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
      'currentlyVisible': true,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, Announcement.fromJson);
  }

  Future<WeatherLog?> getLatestWeather(int skiResortId) async {
    final json = await _api.get('/api/SkiResorts/$skiResortId/weather/latest');
    return json is Map<String, dynamic> ? WeatherLog.fromJson(json) : null;
  }

  Future<PagedResult<Benefit>> searchBenefits({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    int? categoryId,
    double? minRating,
    String? sortBy,
    bool sortDescending = false,
  }) async {
    final json = await _api.get('/api/Benefits', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'benefitCategoryId': categoryId,
      'minAverageRating': minRating,
      'isActive': true,
      'sortBy': sortBy,
      'sortDescending': sortDescending,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, Benefit.fromJson);
  }

  Future<Benefit> getBenefit(int id) async {
    final json = await _api.get('/api/Benefits/$id');
    return Benefit.fromJson(json as Map<String, dynamic>);
  }

  /// Evidentira pregled pogodnosti. Ovi zapisi su ulaz u sistem preporuke,
  /// pa se salju stvarno pri svakom otvaranju detalja.
  Future<void> trackBenefitView(int benefitId, int durationSeconds) async {
    await _api.post('/api/Benefits/$benefitId/views', body: {
      'benefitId': benefitId,
      'durationSeconds': durationSeconds,
    });
  }

  Future<List<RecommendedBenefit>> getRecommendedBenefits({int take = 10}) async {
    final json = await _api.get('/api/Recommendations/benefits', query: {'take': take});
    if (json is! List) return const [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(RecommendedBenefit.fromJson)
        .toList(growable: false);
  }

  Future<List<Lookup>> lookup(String resource) async {
    final json = await _api.get('/api/$resource/lookup');
    if (json is! List) return const [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(Lookup.fromJson)
        .toList(growable: false);
  }
}
