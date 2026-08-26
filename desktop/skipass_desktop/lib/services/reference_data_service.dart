import '../core/api/api_client.dart';
import '../models/paged_result.dart';
import '../models/reference_item.dart';

/// Opisuje jednu referentnu tabelu: putanju API resursa i polja koja tabela
/// stvarno koristi. Isti genericki servis opsluzuje svih osam referentnih
/// tabela umjesto da se identicna CRUD logika ponavlja za svaku posebno.
class ReferenceTableConfig {
  const ReferenceTableConfig({
    required this.resource,
    required this.label,
    required this.singularLabel,
    this.hasIsoCode = false,
    this.hasPostalCode = false,
    this.hasColor = false,
    this.hasSortOrder = false,
    this.hasIcon = false,
    this.hasCode = false,
    this.hasDescription = false,
    this.hasUrgentFlag = false,
    this.hasOnlineFlag = false,
    this.hasActiveFlag = false,
    this.hasCountry = false,
  });

  final String resource;
  final String label;
  final String singularLabel;
  final bool hasIsoCode;
  final bool hasPostalCode;
  final bool hasColor;
  final bool hasSortOrder;
  final bool hasIcon;
  final bool hasCode;
  final bool hasDescription;
  final bool hasUrgentFlag;
  final bool hasOnlineFlag;
  final bool hasActiveFlag;
  final bool hasCountry;

  static const List<ReferenceTableConfig> all = [
    ReferenceTableConfig(
      resource: 'Countries',
      label: 'Drzave',
      singularLabel: 'Drzava',
      hasIsoCode: true,
    ),
    ReferenceTableConfig(
      resource: 'Cities',
      label: 'Gradovi',
      singularLabel: 'Grad',
      hasCountry: true,
      hasPostalCode: true,
    ),
    ReferenceTableConfig(
      resource: 'TrailDifficulties',
      label: 'Tezine staza',
      singularLabel: 'Tezina staze',
      hasColor: true,
      hasSortOrder: true,
      hasDescription: true,
    ),
    ReferenceTableConfig(
      resource: 'LiftTypes',
      label: 'Tipovi liftova',
      singularLabel: 'Tip lifta',
      hasDescription: true,
    ),
    ReferenceTableConfig(
      resource: 'IncidentTypes',
      label: 'Tipovi incidenata',
      singularLabel: 'Tip incidenta',
      hasUrgentFlag: true,
      hasDescription: true,
    ),
    ReferenceTableConfig(
      resource: 'BenefitCategories',
      label: 'Kategorije pogodnosti',
      singularLabel: 'Kategorija pogodnosti',
      hasIcon: true,
      hasDescription: true,
    ),
    ReferenceTableConfig(
      resource: 'AnnouncementCategories',
      label: 'Kategorije obavijesti',
      singularLabel: 'Kategorija obavijesti',
      hasDescription: true,
    ),
    ReferenceTableConfig(
      resource: 'PaymentMethods',
      label: 'Nacini placanja',
      singularLabel: 'Nacin placanja',
      hasCode: true,
      hasOnlineFlag: true,
      hasActiveFlag: true,
    ),
  ];
}

/// Genericki CRUD pristup svim referentnim tabelama.
class ReferenceDataService {
  ReferenceDataService(this._api);

  final ApiClient _api;

  Future<PagedResult<ReferenceItem>> search(
    String resource, {
    int page = 1,
    int pageSize = 50,
    String? query,
    int? countryId,
  }) async {
    final json = await _api.get('/api/$resource', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'countryId': countryId,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, ReferenceItem.fromJson);
  }

  Future<List<Lookup>> lookup(String resource) async {
    final json = await _api.get('/api/$resource/lookup');
    if (json is! List) return const [];
    return json.whereType<Map<String, dynamic>>().map(Lookup.fromJson).toList(growable: false);
  }

  Future<List<Lookup>> citiesByCountry(int countryId) async {
    final json = await _api.get('/api/Cities/lookup/by-country/$countryId');
    if (json is! List) return const [];
    return json.whereType<Map<String, dynamic>>().map(Lookup.fromJson).toList(growable: false);
  }

  Future<ReferenceItem> create(String resource, Map<String, dynamic> body) async {
    final json = await _api.post('/api/$resource', body: body);
    return ReferenceItem.fromJson(json as Map<String, dynamic>);
  }

  Future<ReferenceItem> update(String resource, int id, Map<String, dynamic> body) async {
    final json = await _api.put('/api/$resource/$id', body: body);
    return ReferenceItem.fromJson(json as Map<String, dynamic>);
  }

  Future<void> delete(String resource, int id) async {
    await _api.delete('/api/$resource/$id');
  }
}
