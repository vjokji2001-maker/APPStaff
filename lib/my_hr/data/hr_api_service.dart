import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mate/APIs/api_endpoints.dart';
import 'package:staff_mate/APIs/api_headers.dart';
import 'package:staff_mate/APIs/api_request.dart';
import 'package:staff_mate/APIs/api_host.dart';

class HRApiService {
  static Future<Map<String, String>> _hrHeaders() {
    return ApiHeaders.getHeaders(isHrRequest: true);
  }
  static Future<String> getLoggedEmpId({DateTime? referenceDate}) async {
    final prefs = await SharedPreferences.getInstance();
    String empId = prefs.getString('empId') ?? '';
    
    // If the stored empId is empty or not a valid UUID format (i.e. if it doesn't contain a hyphen)
    // we can attempt to resolve it dynamically from the roster.
    if (empId.isEmpty || !empId.contains('-')) {
      final userId = prefs.getString('userId') ?? '';
      final firstName = prefs.getString('firstName') ?? '';
      if (userId.isNotEmpty) {
        final resolved = await resolveAndSaveEmpIdFromRoster(userId, firstName: firstName, referenceDate: referenceDate);
        if (resolved != null && resolved.isNotEmpty) {
          empId = resolved;
        }
      }
    }
    return empId;
  }

  /// Resolve and save employee ID by querying the shift roster
  static Future<String?> resolveAndSaveEmpIdFromRoster(String userId, {String? firstName, DateTime? referenceDate}) async {
    // Always use current date to resolve empId to maximize chance of finding the active shift
    final now = DateTime.now();
    final fromDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final future = now.add(const Duration(days: 7));
    final toDate = '${future.year}-${future.month.toString().padLeft(2, '0')}-${future.day.toString().padLeft(2, '0')}';
    
    // Query the shift roster for all employees (pageSize: 1000)
    try {
      print('Resolving empId from Shift Roster dashboard for user: $userId (Name: $firstName)...');
      final response = await getShiftRoster(
        fromDate: fromDate,
        toDate: toDate,
        pageSize: 1000, // Fetch all employees so we can locate the current user locally
        empId: "", // Prevents recursive loop
      );
      
      final foundEmpId = _findUserEmpIdInRosterResponse(response, userId: userId, firstName: firstName);
      if (foundEmpId != null && foundEmpId.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('empId', foundEmpId);
        print('Resolved empId successfully from Roster list: $foundEmpId');
        return foundEmpId;
      }
    } catch (e) {
      print('Error querying entire shift roster for resolution: $e');
    }
    
    return null;
  }

  static String? _findUserEmpIdInRosterResponse(dynamic response, {required String userId, String? firstName}) {
    if (response is Map) {
      final dataMap = response['data'];
      List<dynamic>? dataList;
      if (dataMap is List) {
        dataList = dataMap;
      } else if (dataMap is Map) {
        dataList = dataMap['dataList'] ?? dataMap['content'];
      } else {
        dataList = response['dataList'] ?? response['content'];
      }
      
      if (dataList != null && dataList.isNotEmpty) {
        // Flatten dataList in case it contains nested lists (e.g. [[row1, row2]])
        final List<dynamic> flatList = [];
        for (final item in dataList) {
          if (item is List) {
            flatList.addAll(item);
          } else {
            flatList.add(item);
          }
        }
        
        print('Shift Roster fetched ${flatList.length} rows. Looking for match...');
        
        final lowerUserId = userId.toLowerCase();
        final lowerFirstName = firstName?.toLowerCase() ?? '';
        
        // 1. Try matching employeeCode exactly with userId
        for (final row in flatList) {
          if (row is Map) {
            final empCode = row['employeeCode']?.toString().toLowerCase() ?? '';
            if (empCode.isNotEmpty && (empCode == lowerUserId || lowerUserId.contains(empCode) || empCode.contains(lowerUserId))) {
              final empId = row['employeeId']?.toString() ?? row['empId']?.toString();
              if (empId != null && empId.isNotEmpty) {
                print('Match Found by Employee Code: $empCode -> $empId');
                return empId;
              }
            }
          }
        }
        
        // 2. Try matching employeeName with firstName
        if (lowerFirstName.isNotEmpty) {
          for (final row in flatList) {
            if (row is Map) {
              final empName = row['employeeName']?.toString().toLowerCase() ?? '';
              if (empName.isNotEmpty && (empName.contains(lowerFirstName) || lowerFirstName.contains(empName))) {
                final empId = row['employeeId']?.toString() ?? row['empId']?.toString();
                if (empId != null && empId.isNotEmpty) {
                  print('Match Found by Name: $empName -> $empId');
                  return empId;
                }
              }
            }
          }
        }
        
        // 3. Fallback: If there's only 1 row in the roster, it belongs to the logged-in user
        if (flatList.length == 1) {
          final firstRow = flatList.first;
          if (firstRow is Map) {
            final empId = firstRow['employeeId']?.toString() ?? firstRow['empId']?.toString();
            if (empId != null && empId.isNotEmpty) {
              print('Fallback Match: Roster has only 1 row. Using empId: $empId');
              return empId;
            }
          }
        }
      } else {
        print('Shift Roster returned empty list.');
      }
    }
    return null;
  }

  static Future<String> _getEffectiveEmpId(String? empId, {DateTime? referenceDate}) async {
    if (empId != null && empId.isNotEmpty) {
      return empId;
    }
    return await getLoggedEmpId(referenceDate: referenceDate);
  }

  /// Get Employee Profile
  static Future<Map<String, dynamic>> getProfile({String? empId}) async {
    try {
      final id = await _getEffectiveEmpId(empId);
      if (id.isEmpty) throw Exception('Employee ID is missing');
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

  /// Get Year Cycles from master API
  static Future<List<dynamic>> getYearCycles() async {
    try {
      final response = await ApiRequest.post(
        '${ApiHost.hrBaseUrl}/hr/master/year/cycle/get/all',
        {
          "paginationInfo": {
            "pageSize": 1000,
            "currentPage": 1
          },
          "name": "",
          "code": ""
        },
        headers: await _hrHeaders(),
      );
      final data = response is Map ? response['data'] : response;
      return data is List ? data : [];
    } catch (e) {
      print('Error fetching year cycles: $e');
      return [];
    }
  }

  /// Helper to determine the current year cycle ID
  static Future<int?> getCurrentYearCycleId() async {
    final cycles = await getYearCycles();
    if (cycles.isEmpty) return null;
    
    for (final cycle in cycles) {
      if (cycle['status']?.toString().toUpperCase() == 'ACTIVE') {
        return int.tryParse(cycle['id']?.toString() ?? '');
      }
    }
    
    // Fallback to first if no ACTIVE found
    if (cycles.isNotEmpty) {
      return int.tryParse(cycles.first['id']?.toString() ?? '');
    }
    return null;
  }

  /// Get Leave Balance using dynamic user ID and year cycle ID
  static Future<dynamic> getLeaveBalances({String? empId, int? yearId}) async {
    try {
      final id = await _getEffectiveEmpId(empId);
      if (id.isEmpty) throw Exception('Employee ID is missing');
      final resolvedYearId = yearId ?? await getCurrentYearCycleId();
      final body = {
        "employeeId": id,
        if (resolvedYearId != null) "yearId": resolvedYearId,
      };
      
      final response = await ApiRequest.post(
        ApiEndpoints.leaveBalance,
        body,
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error fetching leave balances: $e');
      rethrow;
    }
  }

  /// Get Leave Requests with pagination and dynamic user ID
  static Future<dynamic> getLeaveRequests({
    String? empId,
    int page = 1,
    int pageSize = 10,
    String? fromDate,
    String? toDate,
    String? status,
    String sortingOrder = 'DESC',
    String sortingField = 'lor.app_dt',
    String sortingLabel = 'Application Date',
  }) async {
    try {
      final id = await _getEffectiveEmpId(empId);
      if (id.isEmpty) throw Exception('Employee ID is missing');
      final body = {
        "paginationInfo": {
          "pageSize": pageSize,
          "currentPage": page,
          "dataSorting": {
            "sortingOrder": sortingOrder,
            "byColumn": {
              "label": sortingLabel,
              "field": sortingField
            }
          }
        },
        "fromDate": fromDate,
        "toDate": toDate,
        "empId": id,
        "status": status
      };
      
      final response = await ApiRequest.post(
        ApiEndpoints.leaveDashboard,
        body,
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
    try {
      print('DEBUG: getMyAttendance called with empId: $empId, monthYear: $monthYear');
      final parts = monthYear.split('-');
      DateTime? refDate;
      if (parts.length == 2) {
        refDate = DateTime(int.tryParse(parts[1]) ?? DateTime.now().year, int.tryParse(parts[0]) ?? DateTime.now().month, 1);
      }
      print('DEBUG: refDate parsed as: $refDate');
      final id = await _getEffectiveEmpId(empId, referenceDate: refDate);
      print('DEBUG: effective empId resolved as: $id');
      if (id.isEmpty) throw Exception('Employee ID is missing');
      
      final url = ApiEndpoints.myAttendance(id, monthYear);
      print('DEBUG: making GET request to: $url');
      final response = await ApiRequest.get(
        url,
        headers: await _hrHeaders(),
      );
      print('DEBUG: getMyAttendance response received');
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching attendance: $e');
      rethrow;
    }
  }

  /// Get Holidays
  /// NOTE: Backend requires POST - auto-sends logged-in user's stored data
  static Future<dynamic> getHolidays({
    String name = '',
    String code = '',
    String? year,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentYear = year ?? DateTime.now().year.toString();

      // Read logged-in user stored data from SharedPreferences
      final userId   = prefs.getString('userId') ?? '';
      final empId    = prefs.getString('empId') ?? '';
      final branchId = prefs.get('branchId')?.toString() ?? '';

      final response = await ApiRequest.post(
        ApiEndpoints.holidays,
        {
          'name': name,
          'code': code,
          'year': currentYear,
          // logged-in user info (both camelCase & PascalCase for HRMS compatibility)
          'userId': userId,
          'Userid': userId,
          'empId': empId,
          'Empid': empId,
          'branchId': branchId,
        },
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
    String sortingField = 'ed.formal_name',
    String sortingLabel = 'EmployeeName',
    String sortingOrder = 'ASC',
    String? empId,
    String? jobTitle,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ── Resolve empId: use passed value → stored empId → stored userId ──
      final resolvedEmpId = (empId != null && empId.isNotEmpty)
          ? empId
          : (prefs.getString('empId') ?? prefs.getString('userId') ?? '');

      // ── Resolve jobTitle from preferences ──
      final resolvedJobTitle = jobTitle ??
          prefs.getString('jobtitle') ??
          prefs.getString('UserJobtitle') ??
          prefs.getString('jobTitle') ??
          'admin';

      // ── Resolve employee name for search filter ──
      final resolvedName = searchName.trim().isNotEmpty
          ? searchName.trim()
          : (prefs.getString('firstName') != null
              ? '${prefs.getString('firstName') ?? ''} ${prefs.getString('lastName') ?? ''}'.trim()
              : '');

      final body = {
        'paginationInfo': {
          'pageSize': pageSize,
          'currentPage': page,
          'dataSorting': {
            'sortingOrder': sortingOrder,
            'byColumn': {
              'label': sortingLabel,
              'field': sortingField,   // must be 'ed.formal_name' per API
            },
          },
        },
        'branchId': branchId.isNotEmpty ? branchId : (prefs.get('branchId')?.toString() ?? ''),
        'code': searchCode.trim(),
        'companyId': companyId,
        'departmentId': departmentId,
        'designationId': designationId,
        '#empId': resolvedEmpId,     // field name with # as per actual API payload
        'empId': resolvedEmpId,      // also send without # for compatibility
        'fromDate': fromDate,
        'jobTitle': resolvedJobTitle,
        'name': resolvedName,
        'toDate': toDate,
      };

      debugPrint('=== SHIFT ROSTER PAYLOAD ===');
      debugPrint('URL: ${ApiEndpoints.shiftRosterFetch}');
      debugPrint('empId: $resolvedEmpId');
      debugPrint('fromDate: $fromDate | toDate: $toDate');
      debugPrint('jobTitle: $resolvedJobTitle');

      final response = await ApiRequest.post(
        ApiEndpoints.shiftRosterFetch,
        body,
        headers: await _hrHeaders(),
      );
      return response;
    } catch (e) {
      print('Error fetching shift roster: $e');
      rethrow;
    }
  }


  // --- Leave CRUD ---
  static Future<dynamic> getLeaveRequestById(String id) async {
    return ApiRequest.get(ApiEndpoints.leaveView(id), headers: await _hrHeaders());
  }
  static Future<dynamic> cancelLeaveRequest(Map<String, dynamic> payload) async {
    return ApiRequest.put(ApiEndpoints.leaveCancel, payload, headers: await _hrHeaders());
  }
  static Future<dynamic> deleteLeaveRequest(String id) async {
    return ApiRequest.delete(ApiEndpoints.leaveDelete(id), headers: await _hrHeaders());
  }

  // --- Swipe CRUD ---
  static Future<dynamic> getSwipeDashboard(Map<String, dynamic> payload) async {
    return ApiRequest.post(ApiEndpoints.swipeDashboard, payload, headers: await _hrHeaders());
  }
  static Future<dynamic> createSwipeRequest(Map<String, dynamic> payload) async {
    return ApiRequest.post(ApiEndpoints.swipeCreate, payload, headers: await _hrHeaders());
  }
  static Future<dynamic> getSwipeRequestById(String id) async {
    return ApiRequest.get(ApiEndpoints.swipeView(id), headers: await _hrHeaders());
  }
  static Future<dynamic> updateSwipeRequest(Map<String, dynamic> payload) async {
    return ApiRequest.put(ApiEndpoints.swipeUpdate, payload, headers: await _hrHeaders());
  }
  static Future<dynamic> deleteSwipeRequest(String id) async {
    return ApiRequest.delete(ApiEndpoints.swipeDelete(id), headers: await _hrHeaders());
  }

  // --- OD CRUD ---
  static Future<dynamic> getOdDashboard(Map<String, dynamic> payload) async {
    return ApiRequest.post(ApiEndpoints.odDashboard, payload, headers: await _hrHeaders());
  }
  static Future<dynamic> createOdRequest(Map<String, dynamic> payload) async {
    return ApiRequest.post(ApiEndpoints.odCreate, payload, headers: await _hrHeaders());
  }
  static Future<dynamic> getOdRequestById(String id) async {
    return ApiRequest.get(ApiEndpoints.odView(id), headers: await _hrHeaders());
  }
  static Future<dynamic> cancelOdRequest(Map<String, dynamic> payload) async {
    return ApiRequest.put(ApiEndpoints.odCancel, payload, headers: await _hrHeaders());
  }
  static Future<dynamic> deleteOdRequest(String id) async {
    return ApiRequest.delete(ApiEndpoints.odDelete(id), headers: await _hrHeaders());
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
  /// NOTE: Backend requires POST - auto-sends logged-in user's stored data
  static Future<dynamic> getPayrollSummary({
    int? month,
    int? year,
    int pageSize = 10,
    int currentPage = 1,
    String name = '',
    String code = '',
    String? empId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final selectedMonth = month ?? now.month;
      final selectedYear = year ?? now.year;
      final paddedMonth = selectedMonth.toString().padLeft(2, '0');
      final monthYear = '$selectedYear-$paddedMonth';

      // Read logged-in user stored data from SharedPreferences
      final storedEmpId    = empId ?? prefs.getString('empId') ?? '';
      final storedUserId   = prefs.getString('userId') ?? '';
      final storedBranchId = prefs.get('branchId')?.toString();
      final storedFirstName = prefs.getString('firstName') ?? '';
      final storedLastName  = prefs.getString('lastName') ?? '';

      final response = await ApiRequest.post(
        ApiEndpoints.payrollSummary,
        {
          'monthYear': monthYear,
          'paginationInfo': {
            'pageSize': pageSize,
            'currentPage': currentPage,
            'dataSorting': {
              'sortingOrder': 'ASC',
              'byColumn': {
                'label': 'Name',
                'field': 'ed.formal_name',
              },
            },
          },
          'name': name,
          'code': code,
          'companyId': null,
          'branchId': storedBranchId != null ? int.tryParse(storedBranchId) : null,
          'departmentId': null,
          'designationId': null,
          'workLocationId': null,
          'categoryId': null,
          'gradeId': null,
          'empId': storedEmpId.isNotEmpty ? storedEmpId : null,
          'jobTitle': null,
          // additional user context
          'userId': storedUserId,
          'firstName': storedFirstName,
          'lastName': storedLastName,
        },
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

}
