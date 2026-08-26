import '../core/api/api_client.dart';
import '../core/config/app_config.dart';
import '../models/benefit.dart';
import '../models/order.dart';
import '../models/paged_result.dart';
import '../models/payment.dart';
import '../models/ticket.dart';

/// Kupovina ski pass karata i pogodnosti, te pregled kupljenog.
class PurchaseService {
  PurchaseService(this._api);

  final ApiClient _api;

  Future<PagedResult<SkiPassOrder>> searchOrders({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    String? status,
    DateTime? orderedFrom,
    DateTime? orderedTo,
  }) async {
    final json = await _api.get('/api/Orders', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'status': status,
      'orderedFrom': orderedFrom,
      'orderedTo': orderedTo,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, SkiPassOrder.fromJson);
  }

  Future<SkiPassOrder> getOrder(int id) async {
    final json = await _api.get('/api/Orders/$id');
    return SkiPassOrder.fromJson(json as Map<String, dynamic>);
  }

  /// Salje narudzbu. Cijenu odredjuje server iz cjenovnika, klijent salje samo stavke.
  Future<SkiPassOrder> createOrder({
    required int paymentMethodId,
    required List<OrderDraftItem> items,
    String? note,
  }) async {
    final json = await _api.post('/api/Orders', body: {
      'paymentMethodId': paymentMethodId,
      'note': note,
      'items': items.map((item) => item.toJson()).toList(),
    });
    return SkiPassOrder.fromJson(json as Map<String, dynamic>);
  }

  /// Otvara placanje za narudzbu. Kada je odabrani nacin placanja online, server
  /// vraca Stripe PaymentIntent podatke za PaymentSheet; za placanje na licu mjesta
  /// (npr. gotovina) samo evidentira zapocelo placanje koje osoblje kasnije potvrdjuje.
  Future<PaymentInitiation> initiatePayment({
    required int orderId,
    required int paymentMethodId,
  }) async {
    final json = await _api.post('/api/Payments', body: {
      'skiPassOrderId': orderId,
      'paymentMethodId': paymentMethodId,
    });
    return PaymentInitiation.fromJson(json as Map<String, dynamic>);
  }

  Future<SkiPassOrder> cancelOrder(int id, String reason) async {
    final json = await _api.patch('/api/Orders/$id/status', body: {
      'status': 'Cancelled',
      'cancellationReason': reason,
    });
    return SkiPassOrder.fromJson(json as Map<String, dynamic>);
  }

  Future<PagedResult<SkiPassTicket>> searchTickets({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    String? status,
    DateTime? validOnDate,
  }) async {
    final json = await _api.get('/api/Tickets', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'status': status,
      'validOnDate': validOnDate == null ? null : _dateOnly(validOnDate),
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, SkiPassTicket.fromJson);
  }

  Future<PagedResult<BenefitPurchase>> searchBenefitPurchases({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    String? status,
  }) async {
    final json = await _api.get('/api/benefit-purchases', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'status': status,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, BenefitPurchase.fromJson);
  }

  Future<BenefitPurchase> buyBenefit(int benefitId, int quantity) async {
    final json = await _api.post('/api/benefit-purchases', body: {
      'benefitId': benefitId,
      'quantity': quantity,
    });
    return BenefitPurchase.fromJson(json as Map<String, dynamic>);
  }

  Future<BenefitPurchase> cancelBenefitPurchase(int id, String reason) async {
    final json = await _api.patch('/api/benefit-purchases/$id/status', body: {
      'status': 'Cancelled',
      'cancellationReason': reason,
    });
    return BenefitPurchase.fromJson(json as Map<String, dynamic>);
  }

  static String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
