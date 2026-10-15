import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mate/APIs/api_client.dart';
import 'package:staff_mate/api/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'old',
      'access_token': 'old',
      'refresh_token': 'refresh',
      'two_factor_verified': true,
    });
    ApiService.clearSession();
  });
  tearDown(ApiService.clearSession);

  test('concurrent refresh attempts send one request', () async {
    var calls = 0;
    final results = await http.runWithClient(
      () => Future.wait([
        ApiService.refreshUserToken(),
        ApiService.refreshUserToken(),
      ]),
      () => MockClient((request) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return http.Response(
          jsonEncode({
            'data': {
              'token': 'new',
              'refreshToken': 'new-refresh',
              'expirytime': DateTime.now()
                  .add(const Duration(hours: 1))
                  .toIso8601String(),
            },
          }),
          200,
        );
      }),
    );
    expect(calls, 1);
    expect(results, [true, true]);
  });

  test('logout invalidates an in-flight refresh response', () async {
    final result = await http.runWithClient(
      () => ApiService.refreshUserToken(),
      () => MockClient((request) async {
        ApiService.clearSession();
        return http.Response(
          jsonEncode({
            'data': {'token': 'unexpected-token'},
          }),
          200,
        );
      }),
    );
    expect(result, false);
    expect(ApiService.accessToken, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access_token'), 'old');
  });

  test(
    'retries unauthorized requests only once and uses the refreshed token',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      var requests = 0;
      var refreshes = 0;
      final response = await http.runWithClient(
        () => container
            .read(apiClientProvider)
            .get(
              'https://example.test/patients?ward=1',
              headers: {'Authorization': 'Bearer old'},
            ),
        () => MockClient((request) async {
          if (request.url.path == '/security/auth/refresh') {
            refreshes++;
            return http.Response(
              jsonEncode({
                'data': {
                  'token': 'new',
                  'refreshToken': 'new-refresh',
                  'expirytime': DateTime.now()
                      .add(const Duration(hours: 1))
                      .toIso8601String(),
                },
              }),
              200,
            );
          }
          requests++;
          expect(request.url.queryParameters['ward'], '1');
          expect(
            request.headers['Authorization'],
            requests == 1 ? 'Bearer old' : 'Bearer new',
          );
          return http.Response('{}', 401);
        }),
      );
      expect(response.statusCode, 401);
      expect(requests, 2);
      expect(refreshes, 1);
    },
  );
}
