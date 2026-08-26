import '../core/api/api_client.dart';
import '../models/report.dart';

/// Agregatni izvjestaji za sekciju Izvjestaji.
class ReportService {
  ReportService(this._api);

  final ApiClient _api;

  Future<SalesReport> getSalesByDay({required DateTime dateFrom, required DateTime dateTo, int? skiResortId}) async {
    final json = await _api.get('/api/Reports/sales-by-day', query: {
      'DateFrom': _dateOnly(dateFrom),
      'DateTo': _dateOnly(dateTo),
      'SkiResortId': skiResortId,
    });
    return SalesReport.fromJson(json as Map<String, dynamic>);
  }

  Future<TopUsersReport> getTopUsers({int top = 5}) async {
    final json = await _api.get('/api/Reports/top-users', query: {'top': top});
    return TopUsersReport.fromJson(json as Map<String, dynamic>);
  }

  static String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
