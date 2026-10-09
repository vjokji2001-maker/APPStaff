import 'package:flutter_test/flutter_test.dart';
import 'package:staff_mate/core/api_result.dart';
import 'package:staff_mate/core/auth_session.dart';

void main() {
  group('AuthSession', () {
    test('creates a valid session from response data', () {
      final session = AuthSession.fromJson({
        'token': 'abc',
        'refreshToken': 'refresh-123',
        'expirytime': '2026-10-10T12:00:00',
        'userId': 'user-42',
        'clinicid': 'clinic-7',
        'zoneid': 'Asia/Kolkata',
        'branch_id': '9',
        'subscription_remaining_days': 18,
      });

      expect(session.accessToken, 'abc');
      expect(session.refreshToken, 'refresh-123');
      expect(session.userId, 'user-42');
      expect(session.clinicId, 'clinic-7');
      expect(session.zoneId, 'Asia/Kolkata');
      expect(session.branchId, '9');
      expect(session.subscriptionRemainingDays, 18);
    });
  });

  group('ApiResult', () {
    test('returns failure result with message', () {
      final result = ApiResult<String>.failure(
        ApiFailure(message: 'Unauthorized', statusCode: 401),
      );

      expect(result.isSuccess, isFalse);
      expect(result.failure?.message, 'Unauthorized');
    });
  });
}
