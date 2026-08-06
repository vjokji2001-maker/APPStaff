import 'package:staff_mate/APIs/api_endpoints.dart';
import 'package:staff_mate/APIs/api_headers.dart';
import 'package:staff_mate/APIs/api_request.dart';

class HRApiService {
  static Future<Map<String, String>> _hrHeaders() {
    return ApiHeaders.getHeaders(isHrRequest: true);
  }
  static const String _defaultEmpId = '0086bd62-d49a-4cb9-8818-aa7955db1c63'; // Temporary until we have real auth user ID

  /// Get Employee Profile
  static Future<Map<String, dynamic>> getProfile({String? empId}) async {
    final id = empId ?? _defaultEmpId;
    try {
      final response = await ApiRequest.get(
        ApiEndpoints.employeeProfile(id),
        headers: await _hrHeaders(),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }

  /// Get Leave Balance
 /// Get Leave Balance
static Future<dynamic> getLeaveBalances() async {
  try {
    final response = await ApiRequest.post(
      ApiEndpoints.leaveBalance,
       {},
      headers: await _hrHeaders(),
    );
    return response;
  } catch (e) {
    print('Error fetching leave balances: $e');
    rethrow;
  }
}

  /// Get Leave Requests
  static Future<dynamic> getLeaveRequests() async {
    try {
      final response = await ApiRequest.post(
        ApiEndpoints.leaveDashboard,
        {},
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error fetching leave requests: $e');
      rethrow;
    }
  }

  /// Apply for Leave
  static Future<Map<String, dynamic>> applyLeave(Map<String, dynamic> data) async {
    try {
      final response = await ApiRequest.post(
        ApiEndpoints.leaveCreate,
        data,
        headers: await _hrHeaders(),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error applying leave: $e');
      rethrow;
    }
  }

  /// Get Swipe Regularization Requests
  static Future<dynamic> getSwipeRequests() async {
    try {
      final response = await ApiRequest.get(
        ApiEndpoints.swipeDashboard,
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error fetching swipe requests: $e');
      rethrow;
    }
  }

  /// Get My Attendance
  static Future<Map<String, dynamic>> getMyAttendance({String? empId, required String monthYear}) async {
    final id = empId ?? _defaultEmpId;
    try {
      final response = await ApiRequest.get(
        ApiEndpoints.myAttendance(id, monthYear),
        headers: await _hrHeaders(),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching attendance: $e');
      rethrow;
    }
  }

  /// Get Holidays
  static Future<dynamic> getHolidays() async {
    try {
      final response = await ApiRequest.get(
        ApiEndpoints.holidays,
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error fetching holidays: $e');
      rethrow;
    }
  }

  /// Get Shift Roster
  static Future<dynamic> getShiftRoster({
    required String fromDate,
    required String toDate,
    String searchName = '',
    String searchCode = '',
    String companyId = '',
    String branchId = '',
    String departmentId = '',
    String designationId = '',
    int page = 1,
    int pageSize = 10,
    String sortingField = 'employeeName',
    String sortingLabel = 'EmployeeName',
    String sortingOrder = 'ASC',
  }) async {
    try {
      final response = await ApiRequest.post(
        ApiEndpoints.shiftRosterFetch,
        {
          'paginationInfo': {
            'pageSize': pageSize,
            'currentPage': page,
            'dataSorting': {
              'sortingOrder': sortingOrder,
              'byColumn': {
                'label': sortingLabel,
                'field': sortingField,
              },
            },
          },
          'fromDate': fromDate,
          'toDate': toDate,
          'name': searchName.trim(),
          'code': searchCode.trim(),
          'companyId': companyId,
          'branchId': branchId,
          'designationId': designationId,
          'departmentId': departmentId,
        },
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error fetching shift roster: $e');
      rethrow;
    }
  }

  /// Update Shift Roster
  static Future<dynamic> updateShiftRoster(List<Map<String, dynamic>> data) async {
    try {
      final response = await ApiRequest.put(
        ApiEndpoints.shiftRosterUpdate,
        data,
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error updating shift roster: $e');
      rethrow;
    }
  }

  /// Get Shift Templates
  static Future<dynamic> getShiftTemplates({
    String searchName = '',
    String searchCode = '',
  }) async {
    try {
      final response = await ApiRequest.post(
        ApiEndpoints.shiftTemplateFetch,
        {
          'name': searchName.trim(),
          'code': searchCode.trim(),
        },
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error fetching shift templates: $e');
      rethrow;
    }
  }

  /// Create Shift Template
  static Future<dynamic> createShiftTemplate(Map<String, dynamic> data) async {
    try {
      final response = await ApiRequest.post(
        ApiEndpoints.shiftTemplateCreate,
        data,
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error creating shift template: $e');
      rethrow;
    }
  }

  /// Update Shift Template
  static Future<dynamic> updateShiftTemplate(Map<String, dynamic> data) async {
    try {
      final response = await ApiRequest.put(
        ApiEndpoints.shiftTemplateUpdate,
        data,
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error updating shift template: $e');
      rethrow;
    }
  }

  /// Delete Shift Template
  static Future<dynamic> deleteShiftTemplate(String id) async {
    try {
      final response = await ApiRequest.delete(
        ApiEndpoints.shiftTemplateDelete(id),
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error deleting shift template: $e');
      rethrow;
    }
  }

  /// Get Payroll Summary
  static Future<dynamic> getPayrollSummary() async {
    try {
      final response = await ApiRequest.get(
        ApiEndpoints.payrollSummary,
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error fetching payroll summary: $e');
      rethrow;
    }
  }

  /// Get OD Requests
  static Future<List<dynamic>> getODRequests() async {
    try {
      final response = await ApiRequest.get(
        ApiEndpoints.odDashboard,
        headers: await _hrHeaders(),
      );
      return response as List<dynamic>;
    } catch (e) {
      print('Error fetching OD requests: $e');
      rethrow;
    }
  }

  /// Create Swipe Request
  static Future<Map<String, dynamic>> createSwipeRequest(Map<String, dynamic> data) async {
    try {
      final response = await ApiRequest.post(
        ApiEndpoints.swipeCreate,
        data,
        headers: await _hrHeaders(),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error creating swipe request: $e');
      rethrow;
    }
  }

  /// Create OD Request
  static Future<Map<String, dynamic>> createODRequest(Map<String, dynamic> data) async {
    try {
      final response = await ApiRequest.post(
        ApiEndpoints.odCreate,
        data,
        headers: await _hrHeaders(),
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error creating OD request: $e');
      rethrow;
    }
  }
}
