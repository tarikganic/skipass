import 'dart:io';

import '../core/api/api_client.dart';
import '../core/config/app_config.dart';
import '../models/benefit.dart';
import '../models/paged_result.dart';
import '../models/partner.dart';

/// Pogodnosti i partneri.
class BenefitService {
  BenefitService(this._api);

  final ApiClient _api;

  Future<PagedResult<Benefit>> searchBenefits({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    int? categoryId,
  }) async {
    final json = await _api.get('/api/Benefits', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'benefitCategoryId': categoryId,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, Benefit.fromJson);
  }

  Future<Benefit> getBenefit(int id) async {
    final json = await _api.get('/api/Benefits/$id');
    return Benefit.fromJson(json as Map<String, dynamic>);
  }

  Future<Benefit> createBenefit(Map<String, dynamic> body) async {
    final json = await _api.post('/api/Benefits', body: body);
    return Benefit.fromJson(json as Map<String, dynamic>);
  }

  Future<Benefit> updateBenefit(int id, Map<String, dynamic> body) async {
    final json = await _api.put('/api/Benefits/$id', body: body);
    return Benefit.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteBenefit(int id) async {
    await _api.delete('/api/Benefits/$id');
  }

  Future<PagedResult<Partner>> searchPartners({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
  }) async {
    final json = await _api.get('/api/Partners', query: {'page': page, 'pageSize': pageSize, 'query': query});
    return PagedResult.fromJson(json as Map<String, dynamic>, Partner.fromJson);
  }

  Future<Partner> createPartner(Map<String, dynamic> body) async {
    final json = await _api.post('/api/Partners', body: body);
    return Partner.fromJson(json as Map<String, dynamic>);
  }

  Future<Partner> updatePartner(int id, Map<String, dynamic> body) async {
    final json = await _api.put('/api/Partners/$id', body: body);
    return Partner.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deletePartner(int id) async {
    await _api.delete('/api/Partners/$id');
  }

  Future<String> uploadImage(File file) async {
    final json = await _api.uploadFile('/api/Files/images/benefits', file);
    return (json as Map<String, dynamic>)['url'] as String;
  }
}
