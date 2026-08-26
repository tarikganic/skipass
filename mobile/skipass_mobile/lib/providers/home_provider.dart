import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../models/home_summary.dart';
import '../models/recommended_benefit.dart';
import '../services/catalog_service.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider(this._catalogService);

  final CatalogService _catalogService;

  HomeSummary? _summary;
  List<RecommendedBenefit> _recommendedBenefits = const [];
  bool _isLoading = false;
  String? _errorMessage;

  HomeSummary? get summary => _summary;
  List<RecommendedBenefit> get recommendedBenefits => _recommendedBenefits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _summary != null;

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _catalogService.getHomeSummary(),
        _catalogService.getRecommendedBenefits(take: 6).catchError((_) => const <RecommendedBenefit>[]),
      ]);
      _summary = results[0] as HomeSummary;
      _recommendedBenefits = results[1] as List<RecommendedBenefit>;
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _summary = null;
    _recommendedBenefits = const [];
    _errorMessage = null;
    notifyListeners();
  }
}
