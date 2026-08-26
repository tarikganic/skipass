import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/config/app_config.dart';
import '../models/order.dart';
import '../models/paged_result.dart';
import '../models/ticket.dart';

/// Karte, narudzbe, tipovi karata i placanja - administracija prodaje.
class OrderService {
  OrderService(this._api);

  final ApiClient _api;

  // --- Tipovi karata ---

  Future<PagedResult<TicketType>> searchTicketTypes({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    bool? isActive,
  }) async {
    final json = await _api.get('/api/ticket-types', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'isActive': isActive,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, TicketType.fromJson);
  }

  Future<TicketType> createTicketType(Map<String, dynamic> body) async {
    final json = await _api.post('/api/ticket-types', body: body);
    return TicketType.fromJson(json as Map<String, dynamic>);
  }

  Future<TicketType> updateTicketType(int id, Map<String, dynamic> body) async {
    final json = await _api.put('/api/ticket-types/$id', body: body);
    return TicketType.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteTicketType(int id) async {
    await _api.delete('/api/ticket-types/$id');
  }

  // --- Karte ---

  Future<PagedResult<SkiPassTicket>> searchTickets({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    String? status,
  }) async {
    final json = await _api.get('/api/Tickets', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'status': status,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, SkiPassTicket.fromJson);
  }

  /// Odbijena validacija stize kao HTTP 409 sa razlogom u poruci servera;
  /// ovdje se prevodi u rezultat umjesto da se prijavljuje kao neuspjeh poziva.
  Future<TicketValidationResult> validateTicket(String qrCode, int skiLiftId) async {
    try {
      final json = await _api.post('/api/Tickets/validate', body: {
        'qrCode': qrCode,
        'skiLiftId': skiLiftId,
      });
      return TicketValidationResult.fromJson(json as Map<String, dynamic>);
    } on ApiException catch (error) {
      if (!error.isConflict) rethrow;
      return TicketValidationResult(isSuccessful: false, failureReason: error.message);
    }
  }

  // --- Narudzbe ---

  Future<PagedResult<SkiPassOrder>> searchOrders({
    int page = 1,
    int pageSize = AppConfig.pageSize,
    String? query,
    String? status,
  }) async {
    final json = await _api.get('/api/Orders', query: {
      'page': page,
      'pageSize': pageSize,
      'query': query,
      'status': status,
    });
    return PagedResult.fromJson(json as Map<String, dynamic>, SkiPassOrder.fromJson);
  }

  Future<SkiPassOrder> getOrder(int id) async {
    final json = await _api.get('/api/Orders/$id');
    return SkiPassOrder.fromJson(json as Map<String, dynamic>);
  }

  Future<SkiPassOrder> updateOrderStatus(int id, String status, {String? cancellationReason}) async {
    final json = await _api.patch('/api/Orders/$id/status', body: {
      'status': status,
      'cancellationReason': cancellationReason,
    });
    return SkiPassOrder.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteOrder(int id) async {
    await _api.delete('/api/Orders/$id');
  }

  // --- Placanja ---

  Future<Map<String, dynamic>> confirmPayment(int paymentId, String transactionId) async {
    final json = await _api.post('/api/Payments/$paymentId/confirm', body: {'transactionId': transactionId});
    return json as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refundPayment(int paymentId, String reason, {double? amount}) async {
    final json = await _api.post('/api/Payments/$paymentId/refund', body: {'reason': reason, 'amount': amount});
    return json as Map<String, dynamic>;
  }
}

class TicketValidationResult {
  const TicketValidationResult({
    required this.isSuccessful,
    this.ticketHolderName,
    this.failureReason,
    this.skiLiftName,
  });

  final bool isSuccessful;
  final String? ticketHolderName;
  final String? failureReason;
  final String? skiLiftName;

  /// Uspjesna validacija stize kao ravan TicketValidationDto objekat.
  factory TicketValidationResult.fromJson(Map<String, dynamic> json) => TicketValidationResult(
        isSuccessful: json['isSuccessful'] == true,
        ticketHolderName: json['ticketHolderName'] as String?,
        failureReason: json['failureReason'] as String?,
        skiLiftName: json['skiLiftName'] as String?,
      );
}
