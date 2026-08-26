import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipass_mobile/core/api/api_client.dart';
import 'package:skipass_mobile/core/storage/token_storage.dart';

/// Lazni API klijent koji vraca stvarne odgovore snimljene sa pokrenutog servera.
///
/// Testovi tako provjeravaju i parsiranje i prikaz nad istim podacima koje
/// aplikacija dobija u stvarnom radu, bez potrebe za pokrenutim serverom.
class FakeApi {
  FakeApi({Map<String, String>? overrides}) : _overrides = overrides ?? const {};

  final Map<String, String> _overrides;

  /// Putanje zahtjeva koje je aplikacija pozvala, redom.
  final List<String> requestedPaths = [];

  /// Mapiranje putanje zahtjeva na datoteku sa snimljenim odgovorom.
  static const _fixtures = <String, String>{
    '/api/Home/summary': 'home_summary',
    '/api/Trails': 'trails',
    '/api/SkiLifts': 'lifts',
    '/api/Tickets': 'tickets',
    '/api/Benefits': 'benefits',
    '/api/Orders': 'orders',
    '/api/Announcements': 'announcements',
    '/api/Notifications': 'notifications',
    '/api/Recommendations/benefits': 'recommendations',
    '/api/ticket-types': 'ticket_types',
    '/api/Auth/me': 'me',
  };

  ApiClient build() {
    // Token mora postojati da bi klijent slao autorizacijsko zaglavlje.
    SharedPreferences.setMockInitialValues({
      'skipass.access_token': 'test-token',
      'skipass.token_expires_at':
          DateTime.now().add(const Duration(hours: 8)).toIso8601String(),
      'skipass.username': 'mobile',
    });

    final client = MockClient((request) async {
      final path = request.url.path;
      requestedPaths.add(path);

      if (_overrides.containsKey(path)) {
        final override = _overrides[path]!;

        // Oznaka kojom test trazi odgovor sa greskom umjesto uspjesnog odgovora.
        if (override == '__ERROR__') {
          return http.Response(
            '{"message":"Skijaliste trenutno nije dostupno.","traceId":"test-trace"}',
            503,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        return _json(override);
      }

      // Lookup i brojaci se ne snimaju kao datoteke jer su trivijalni.
      if (path.endsWith('/lookup')) {
        return _json('[{"id":1,"name":"Prva"},{"id":2,"name":"Druga"}]');
      }

      if (path == '/api/Notifications/unread-count') {
        return _json('{"unreadCount":3}');
      }

      final fixture = _fixtures[path];
      if (fixture != null) {
        return _json(_read(fixture));
      }

      return http.Response(
        '{"message":"Ruta $path nije pokrivena testom."}',
        404,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    return ApiClient(httpClient: client, tokenStorage: TokenStorage());
  }

  static http.Response _json(String body) => http.Response(
        body,
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

  static String _read(String name) =>
      File('test/fixtures/$name.json').readAsStringSync(encoding: utf8);

  /// Ucitava snimljeni odgovor kao mapu, za direktnu provjeru modela.
  static Map<String, dynamic> readJson(String name) =>
      jsonDecode(_read(name)) as Map<String, dynamic>;
}
