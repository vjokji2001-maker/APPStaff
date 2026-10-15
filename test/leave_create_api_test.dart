import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mate/APIs/api_endpoints.dart';
import 'package:staff_mate/my_hr/data/hr_api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final payload = <String, dynamic>{
    'applicationDate': '2026-10-13',
    'fromDate': '2026-10-13',
    'toDate': '2026-10-24',
    'fromDateDuration': 'FULL_DAY',
    'toDateDuration': 'FULL_DAY',
    'leaveNameId': 4,
    'employeeId': 'test-employee',
    'reason': 'Family commitment',
    'yearId': 2,
    'totalCount': 12.0,
    'approverDTOList': <Map<String, dynamic>>[],
  };
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'auth_token': 'test-token',
      'clinicId': 'test-clinic',
      'userId': 'test-user',
      'empId': 'test-employee',
    }),
  );

  test(
    'create-leave sends expected endpoint, payload and authenticated HR headers',
    () async {
      var calls = 0;
      final response = await HRApiService.applyLeave(
        payload,
        sendRequest: (url, body, headers) async {
          calls++;
          expect(url, ApiEndpoints.leaveCreate);
          expect(url, endsWith('/hr/attendance/leave/request/create'));
          expect(body, payload);
          expect(headers['Authorization'], 'Bearer test-token');
          expect(headers['clinicid'], 'test-clinic_hrms');
          expect(headers['userid'], 'test-user');
          return {
            'success': true,
            'data': {'id': 'request-1'},
          };
        },
      );
      expect(calls, 1);
      expect(response['success'], true);
    },
  );
  test(
    'business errors and missing confirmation do not report success',
    () async {
      for (final response in [
        {'success': false, 'message': 'Insufficient balance'},
        {'status': 'ERROR', 'message': 'Invalid year'},
        {'statusCode': 400, 'message': 'Invalid leave'},
        null,
      ]) {
        await expectLater(
          HRApiService.applyLeave(
            payload,
            sendRequest: (_, _, _) async => response,
          ),
          throwsException,
        );
      }
    },
  );
  test('invalid payload and missing session stop before sending', () async {
    var calls = 0;
    Future<dynamic> send(
      String url,
      Map<String, dynamic> body,
      Map<String, String> headers,
    ) async {
      calls++;
      return {'success': true};
    }

    await expectLater(
      HRApiService.applyLeave({
        ...payload,
        'employeeId': '',
      }, sendRequest: send),
      throwsException,
    );
    SharedPreferences.setMockInitialValues({});
    await expectLater(
      HRApiService.applyLeave(payload, sendRequest: send),
      throwsException,
    );
    expect(calls, 0);
  });
}
