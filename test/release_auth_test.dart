import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mate/APIs/api_headers.dart';
import 'package:staff_mate/api/api_service.dart';
import 'package:staff_mate/services/app_auth_service.dart';
import 'package:staff_mate/services/session_manger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ApiService.clearSession();
  });
  tearDown(ApiService.clearSession);

  test(
    'HR headers preserve existing tenant suffix and the saved timezone',
    () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'Bearer test-token',
        'clinicId': 'clinic_hrms',
        'zoneid': 'Asia/Dubai',
      });
      final headers = await ApiHeaders.getHeaders(isHrRequest: true);
      expect(headers['Authorization'], 'Bearer test-token');
      expect(headers['clinicid'], 'clinic_hrms');
      expect(headers['zoneid'], 'Asia/Dubai');
    },
  );

  test(
    'password login stages OTP headers but cannot resume a trusted session',
    () async {
      final result = await http.runWithClient(
        () => const AppAuthService().login(
          userName: 'staff',
          password: 'password with spaces ',
        ),
        () => MockClient((request) async {
          expect(request.url.path, '/security/auth/login');
          final body = jsonDecode(request.body) as Map;
          expect(body['password'], isNot('password with spaces '));
          return http.Response(
            jsonEncode({
              'data': {
                'token': 'provisional-token',
                'refreshToken': 'refresh-token',
                'userId': 'staff-id',
                'clinicid': 'clinic',
                'subscription_remaining_days': 30,
                'expirytime': DateTime.now()
                    .add(const Duration(hours: 1))
                    .toIso8601String(),
              },
            }),
            200,
          );
        }),
      );
      expect(result.isSuccess, true);
      expect(await SessionManager.hasValidSession(), false);
      expect(
        (await ApiHeaders.getHeaders())['Authorization'],
        'SmartCare provisional-token',
      );
      await SessionManager.set2FAVerified(verified: true);
      expect(await SessionManager.hasValidSession(), true);
      await SessionManager.clearAuthData();
      expect(await SessionManager.hasValidSession(), false);
    },
  );

  test(
    'legacy or unfinished OTP session cannot bypass login at startup',
    () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'old-token',
        'refresh_token': 'refresh',
      });
      expect(await SessionManager.hasValidSession(), false);
    },
  );

  test(
    'refresh synchronizes the token used by both HR and hospital headers',
    () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'old-token',
        'access_token': 'old-token',
        'refresh_token': 'refresh',
        'two_factor_verified': true,
      });
      await SessionManager.saveTokens(
        accessToken: 'new-token',
        refreshToken: 'new-refresh',
        expiryTime: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(await SessionManager.getAccessToken(), 'new-token');
      expect((await SessionManager.getSession())['auth_token'], 'new-token');
      expect(
        (await ApiHeaders.getHeaders())['Authorization'],
        'SmartCare new-token',
      );
      expect(
        (await ApiHeaders.getHeaders(isHrRequest: true))['Authorization'],
        'Bearer new-token',
      );
    },
  );
}
