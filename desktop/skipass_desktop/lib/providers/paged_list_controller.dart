import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../models/paged_result.dart';

/// Zajednicka logika za sve list ekrane: prvo ucitavanje, osvjezavanje,
/// dohvat sljedece stranice i jedinstvena obrada stanja greske.
///
/// Paginacija je obavezna na svakom list endpointu, pa je i klijentska strana
/// izvedena kroz jedan kontroler umjesto da se ista logika ponavlja po ekranima.
class PagedListController<T> extends ChangeNotifier {
  PagedListController({required this.fetchPage, this.pageSize = 20});

  /// Dohvata jednu stranicu sa servera.
  final Future<PagedResult<T>> Function(int page, int pageSize) fetchPage;
  final int pageSize;

  final List<T> _items = [];
  int _page = 1;
  int _totalCount = 0;
  bool _hasNextPage = false;
  bool _isLoadingFirstPage = false;
  bool _isLoadingNextPage = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  bool _disposed = false;

  List<T> get items => List.unmodifiable(_items);
  int get totalCount => _totalCount;
  bool get hasNextPage => _hasNextPage;
  bool get isLoadingFirstPage => _isLoadingFirstPage;
  bool get isLoadingNextPage => _isLoadingNextPage;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;
  bool get isEmpty => _items.isEmpty && !_isLoadingFirstPage && !hasError;

  Future<void> loadFirstPage() async {
    _isLoadingFirstPage = true;
    _errorMessage = null;
    _safeNotify();

    await _load(page: 1, replace: true);

    _isLoadingFirstPage = false;
    _safeNotify();
  }

  /// Ponovo ucitava prvu stranicu bez prikazivanja pune skeleton animacije.
  Future<void> refresh() async {
    _isRefreshing = true;
    _errorMessage = null;
    _safeNotify();

    await _load(page: 1, replace: true);

    _isRefreshing = false;
    _safeNotify();
  }

  Future<void> loadNextPage() async {
    if (!_hasNextPage || _isLoadingNextPage || _isLoadingFirstPage) return;

    _isLoadingNextPage = true;
    _safeNotify();

    await _load(page: _page + 1, replace: false);

    _isLoadingNextPage = false;
    _safeNotify();
  }

  /// Uklanja zapis iz liste bez ponovnog poziva servera (npr. nakon brisanja).
  void removeWhere(bool Function(T item) test) {
    final removed = _items.length;
    _items.removeWhere(test);
    if (_items.length != removed) {
      _totalCount = (_totalCount - (removed - _items.length)).clamp(0, 1 << 31);
      _safeNotify();
    }
  }

  /// Zamjenjuje jedan zapis azuriranom verzijom.
  void replaceWhere(bool Function(T item) test, T updated) {
    final index = _items.indexWhere(test);
    if (index >= 0) {
      _items[index] = updated;
      _safeNotify();
    }
  }

  Future<void> _load({required int page, required bool replace}) async {
    try {
      final result = await fetchPage(page, pageSize);

      if (replace) _items.clear();
      _items.addAll(result.items);
      _page = result.page;
      _totalCount = result.totalCount;
      _hasNextPage = result.hasNextPage;
      _errorMessage = null;
    } on ApiException catch (error) {
      // Poruka servera se prosljedjuje korisniku umjesto genericke poruke.
      _errorMessage = error.message;
      if (replace) _items.clear();
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
