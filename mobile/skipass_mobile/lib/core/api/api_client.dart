import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Jedinstvena tacka komunikacije sa REST API-jem.
///
/// Zaduzena je za dodavanje autorizacijskog zaglavlja, serijalizaciju,
/// prevodjenje HTTP gresaka u [ApiException] i obradu isteklog tokena.
class ApiClient {
  ApiClient({http.Client? httpClient, TokenStorage? tokenStorage})
      : _http = httpClient ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final http.Client _http;
  final TokenStorage _tokenStorage;

  /// Poziva se kada server odbije token, kako bi aplikacija vratila korisnika na prijavu.
  void Function()? onUnauthorized;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() async => _http.get(_uri(path, query), headers: await _headers()));

  Future<dynamic> post(String path, {Object? body, Map<String, dynamic>? query}) =>
      _send(() async => _http.post(
            _uri(path, query),
            headers: await _headers(json: true),
            body: body == null ? null : jsonEncode(body),
          ));

  Future<dynamic> put(String path, {Object? body}) =>
      _send(() async => _http.put(
            _uri(path),
            headers: await _headers(json: true),
            body: body == null ? null : jsonEncode(body),
          ));

  Future<dynamic> patch(String path, {Object? body}) =>
      _send(() async => _http.patch(
            _uri(path),
            headers: await _headers(json: true),
            body: body == null ? null : jsonEncode(body),
          ));

  Future<dynamic> delete(String path) =>
      _send(() async => _http.delete(_uri(path), headers: await _headers()));

  /// Salje datoteku kao multipart zahtjev i vraca odgovor servera.
  Future<dynamic> uploadFile(String path, File file, {String field = 'file'}) async {
    try {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll(await _headers())
        ..files.add(await http.MultipartFile.fromPath(field, file.path));

      final streamed = await request.send().timeout(AppConfig.requestTimeout);
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Zahtjev je predugo trajao. Pokusajte ponovo.');
    }
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final parameters = <String, String>{};

    query?.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      parameters[key] = value is DateTime ? value.toIso8601String() : value.toString();
    });

    return Uri.parse('${AppConfig.apiBaseUrl}$normalized')
        .replace(queryParameters: parameters.isEmpty ? null : parameters);
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) headers['Content-Type'] = 'application/json';

    final token = await _tokenStorage.readToken();
    if (token != null) headers['Authorization'] = 'Bearer $token';

    return headers;
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(AppConfig.requestTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on HandshakeException {
      throw NetworkException('Sigurna veza sa serverom nije uspostavljena.');
    } on TimeoutException {
      throw NetworkException('Zahtjev je predugo trajao. Pokusajte ponovo.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;

    if (status == 401) {
      onUnauthorized?.call();
      throw ApiException(
        message: 'Sesija je istekla. Molimo prijavite se ponovo.',
        statusCode: status,
      );
    }

    if (status >= 200 && status < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }

    throw _toException(response);
  }

  /// Prosljedjuje poruku koju je server poslao, umjesto genericke poruke o gresci.
  ApiException _toException(http.Response response) {
    String message = 'Doslo je do greske pri komunikaciji sa serverom.';
    final fieldErrors = <String, List<String>>{};
    String? traceId;

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] is String && (decoded['message'] as String).isNotEmpty) {
          message = decoded['message'] as String;
        }
        traceId = decoded['traceId'] as String?;

        final errors = decoded['errors'];
        if (errors is Map<String, dynamic>) {
          errors.forEach((key, value) {
            if (value is List) {
              fieldErrors[key] = value.map((e) => e.toString()).toList();
            }
          });
        }
      }
    } on FormatException {
      // Tijelo nije JSON - ostaje podrazumijevana poruka.
    }

    if (fieldErrors.isNotEmpty && message.isEmpty) {
      message = fieldErrors.values.first.first;
    }

    return ApiException(
      message: message,
      statusCode: response.statusCode,
      fieldErrors: fieldErrors,
      traceId: traceId,
    );
  }

  void dispose() => _http.close();
}
