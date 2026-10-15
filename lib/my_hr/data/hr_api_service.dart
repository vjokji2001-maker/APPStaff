import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mate/APIs/api_endpoints.dart';
import 'package:staff_mate/APIs/api_headers.dart';
import 'package:staff_mate/APIs/api_request.dart';
import 'package:staff_mate/APIs/api_host.dart';
import '../models/hr_models.dart';
import '../utils/leave_form_rules.dart';

class HRApiService {
  static Future<Map<String, String>> _hrHeaders() {
    return ApiHeaders.getHeaders(isHrRequest: true);
  }

  static Future<String> getLoggedEmpId({DateTime? referenceDate}) async {
    final prefs = await SharedPreferences.getInstance();

    String empId = prefs.getString('empId')?.trim() ?? '';

    print('========== GET LOGGED EMP ID ==========');
    print('Stored empId: $empId');

    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-'
      r'[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{12}$',
    );

    // Use stored Employee ID if it is a valid UUID.
    if (uuidRegex.hasMatch(empId)) {
      print('Using stored Employee ID: $empId');
      return empId;
    }

    // Otherwise resolve Employee ID from Shift Roster.
    final userId = prefs.getString('userId')?.trim() ?? '';
    final employeeCode = prefs.getString('empCode')?.trim() ?? '';
    final employeeName =
        '${prefs.getString('firstName') ?? ''} ${prefs.getString('lastName') ?? ''}'
            .trim();

    print('Stored Employee ID invalid/missing.');
    print('userId: $userId');
    print('employeeName: $employeeName');

    if (userId.isNotEmpty) {
      final resolved = await resolveAndSaveEmpIdFromRoster(
        userId,
        employeeCode: employeeCode,
        firstName: employeeName,
        referenceDate: referenceDate,
      );

      if (resolved != null && resolved.isNotEmpty) {
        print('Resolved Employee ID: $resolved');
        return resolved;
      }
    }

    print('Could not resolve Employee ID.');
    return '';
  }

  /// Resolve and save employee ID by querying the shift roster
  static Future<String?> resolveAndSaveEmpIdFromRoster(
    String userId, {
    String? employeeCode,
    String? firstName,
    DateTime? referenceDate,
  }) async {
    // Always use current date to resolve empId to maximize chance of finding the active shift
    final now = DateTime.now();
    final fromDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final future = now.add(const Duration(days: 7));
    final toDate =
        '${future.year}-${future.month.toString().padLeft(2, '0')}-${future.day.toString().padLeft(2, '0')}';

    // Query the shift roster for all employees (pageSize: 1000)
    try {
      print(
        'Resolving empId from Shift Roster dashboard for user: $userId (Name: $firstName)...',
      );
      final response = await getShiftRoster(
        fromDate: fromDate,
        toDate: toDate,
        pageSize:
            1000, // Fetch all employees so we can locate the current user locally
        resolveAllEmployees: true,
      );

      final foundEmpId = _findUserEmpIdInRosterResponse(
        response,
        userId: userId,
        employeeCode: employeeCode,
        firstName: firstName,
      );
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

  static String? _findUserEmpIdInRosterResponse(
    dynamic response, {
    required String userId,
    String? employeeCode,
    String? firstName,
  }) {
    if (response is! Map) {
      return null;
    }

    final dataMap = response['data'];
    List<dynamic>? dataList;

    if (dataMap is List) {
      dataList = dataMap;
    } else if (dataMap is Map) {
      dataList =
          dataMap['dataList'] ?? dataMap['content'] ?? dataMap['records'];
    } else {
      dataList =
          response['dataList'] ?? response['content'] ?? response['records'];
    }

    if (dataList == null || dataList.isEmpty) {
      print('Shift Roster returned empty list.');
      return null;
    }

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

    // TEMP DEBUG: inspect roster field names and matching values
    if (flatList.isNotEmpty) {
      // TEMP DEBUG: print every employee returned by the roster.
      for (final row in flatList) {
        if (row is Map) {
          print(
            'ROSTER EMPLOYEE: '
            'name=${row['employeeName']}, '
            'code=${row['employeeCode']}, '
            'employeeId=${row['employeeId']}',
          );
        }
      }
      for (final row in flatList) {
        if (row is Map) {
          final rowText = row.toString().toLowerCase();

          if (rowText.contains(userId.toLowerCase()) ||
              rowText.contains((firstName ?? '').toLowerCase())) {
            print('ROSTER POSSIBLE MATCH: $row');
          }
        }
      }
    }

    final lowerUserId = userId.toLowerCase();
    final lowerEmployeeCode = employeeCode?.toLowerCase() ?? '';
    final lowerEmployeeName = firstName?.trim().toLowerCase() ?? '';

    // 1. Match employee code against the login user ID or employee code.
    for (final row in flatList) {
      if (row is! Map) continue;

      final empCode =
          row['employeeCode']?.toString().trim().toLowerCase() ?? '';

      if (empCode.isNotEmpty &&
          (empCode == lowerUserId ||
              (lowerEmployeeCode.isNotEmpty && empCode == lowerEmployeeCode))) {
        final empId =
            (row['employeeId'] ?? row['empId'])?.toString().trim() ?? '';

        if (empId.isNotEmpty && empId != 'null') {
          print('Match Found by Employee Code: $empCode -> $empId');
          return empId;
        }
      }
    }

    // 2. Match the full employee name.
    if (lowerEmployeeName.isNotEmpty) {
      for (final row in flatList) {
        if (row is! Map) continue;

        final empName =
            row['employeeName']?.toString().trim().toLowerCase() ?? '';

        if (empName == lowerEmployeeName) {
          final empId =
              (row['employeeId'] ?? row['empId'])?.toString().trim() ?? '';

          if (empId.isNotEmpty && empId != 'null') {
            print('Match Found by Name: $empName -> $empId');
            return empId;
          }
        }
      }
    }

    return null;
  }

  static Future<String> _getEffectiveEmpId(
    String? empId, {
    DateTime? referenceDate,
  }) async {
    final suppliedEmpId = empId?.trim() ?? '';
    if (suppliedEmpId.isNotEmpty) {
      return suppliedEmpId;
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
    final url = '${ApiHost.hrBaseUrl}/hr/master/year/cycle/get/all';

    try {
      final response = await ApiRequest.post(url, {
        'paginationInfo': {'pageSize': 1000, 'currentPage': 1},
        'name': '',
        'code': '',
      }, headers: await _hrHeaders());

      debugPrint('========== YEAR CYCLE DEBUG ==========');
      debugPrint('URL: $url');
      debugPrint('Response type: ${response.runtimeType}');
      debugPrint('Response: $response');

      dynamic data = response;

      // Unwrap common response structures.
      for (int i = 0; i < 4 && data is Map; i++) {
        final map = Map<String, dynamic>.from(data);

        // Stop if the response itself looks like a year-cycle record.
        if (map.containsKey('id') ||
            map.containsKey('yearId') ||
            map.containsKey('cycleId')) {
          break;
        }

        dynamic next;
        for (final key in [
          'data',
          'dataList',
          'content',
          'records',
          'items',
          'result',
        ]) {
          if (map[key] != null) {
            next = map[key];
            break;
          }
        }

        if (next == null || identical(next, data)) break;
        data = next;
      }

      if (data is List) {
        debugPrint('Year cycles found: ${data.length}');
        return data;
      }

      debugPrint(
        'No year-cycle list found. Inspect the response printed above.',
      );
      return [];
    } catch (e, stackTrace) {
      debugPrint('YEAR CYCLE ERROR: $e');
      debugPrint('$stackTrace');
      return [];
    }
  }

  /// Get Leave Templates
  static Future<List<LeaveTemplate>> getLeaveTemplates({
    String name = '',
    String code = '',
  }) async {
    try {
      final response = await ApiRequest.post(
        '${ApiHost.hrBaseUrl}/hr/master/attendance/leaveTemplate/get/all',
        {'name': name, 'code': code},
        headers: await _hrHeaders(),
      );

      dynamic data = response;
      for (var i = 0; i < 4 && data is Map; i++) {
        data =
            data['data'] ??
            data['dataList'] ??
            data['content'] ??
            data['records'] ??
            data['items'];
      }

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) => LeaveTemplate.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      return <LeaveTemplate>[];
    } catch (e) {
      print('Error fetching leave templates: $e');
      rethrow;
    }
  }

  /// Helper to determine the current year cycle ID
  static Future<int?> getCurrentYearCycleId() async {
    final cycles = await getYearCycles();
    return LeaveFormRules.currentCycleId(cycles, DateTime.now());
  }

  /// Get Leave Balance using dynamic user ID and year cycle ID
  /// Get Leave Balance using dynamic user ID and year cycle ID
  static Future<dynamic> getLeaveBalances({String? empId, int? yearId}) async {
    try {
      debugPrint('========================================');
      debugPrint('        LEAVE BALANCE API TEST');
      debugPrint('========================================');

      // Resolve Employee ID
      final id = await _getEffectiveEmpId(empId);

      debugPrint('Leave Employee ID: $id');

      if (id.isEmpty) {
        throw Exception('Employee ID is missing');
      }

      // Resolve Year Cycle ID
      final resolvedYearId = yearId ?? await getCurrentYearCycleId();

      debugPrint('Leave Year Cycle ID: $resolvedYearId');

      // Request body
      final body = {
        "employeeId": id,
        if (resolvedYearId != null) "yearId": resolvedYearId,
      };

      debugPrint('Leave API URL: ${ApiEndpoints.leaveBalance}');
      debugPrint('Leave API Method: POST');
      debugPrint('Leave API Body: $body');

      // Headers
      final headers = await _hrHeaders();

      debugPrint('Leave API Headers: $headers');

      // API request
      final response = await ApiRequest.post(
        ApiEndpoints.leaveBalance,
        body,
        headers: headers,
      );

      debugPrint('----------------------------------------');
      debugPrint('LEAVE API RESPONSE RECEIVED');
      debugPrint('Response Type: ${response.runtimeType}');
      debugPrint('Response: $response');
      debugPrint('----------------------------------------');

      return response;
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('        LEAVE BALANCE API ERROR');
      debugPrint('========================================');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('========================================');

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

      if (id.isEmpty) {
        throw Exception('Employee ID is missing');
      }

      final body = {
        "paginationInfo": {
          "pageSize": pageSize,
          "currentPage": page,
          "dataSorting": {
            "sortingOrder": sortingOrder,
            "byColumn": {"label": sortingLabel, "field": sortingField},
          },
        },
        "fromDate": fromDate,
        "toDate": toDate,
        "empId": id,
        "status": status,
      };

      print('LEAVE DASHBOARD URL: ${ApiEndpoints.leaveDashboard}');
      print('LEAVE DASHBOARD PAYLOAD: $body');

      final response = await ApiRequest.post(
        ApiEndpoints.leaveDashboard,
        body,
        headers: await _hrHeaders(),
      );

      print('LEAVE DASHBOARD RESPONSE TYPE: ${response.runtimeType}');
      print('LEAVE DASHBOARD RESPONSE: $response');

      return response;
    } catch (e, stackTrace) {
      print('ERROR FETCHING LEAVE REQUESTS: $e');
      print(stackTrace);
      rethrow;
    }
  }

  /// Apply for Leave
  static Future<Map<String, dynamic>> applyLeave(
    Map<String, dynamic> data, {
    Future<dynamic> Function(String, Map<String, dynamic>, Map<String, String>)?
    sendRequest,
  }) async {
    try {
      final from = DateTime.tryParse(data['fromDate']?.toString() ?? '');
      final to = DateTime.tryParse(data['toDate']?.toString() ?? '');
      final applicationDate = DateTime.tryParse(
        data['applicationDate']?.toString() ?? '',
      );
      const durations = {'FULL_DAY', 'FIRST_HALF', 'SECOND_HALF'};
      if (from == null ||
          to == null ||
          applicationDate == null ||
          !durations.contains(data['fromDateDuration']) ||
          !durations.contains(data['toDateDuration'])) {
        throw Exception('Please provide valid leave dates and durations.');
      }
      final expectedDays = LeaveFormRules.totalDays(
        from,
        to,
        data['fromDateDuration'] as String,
        data['toDateDuration'] as String,
      );
      if (expectedDays <= 0 ||
          expectedDays != num.tryParse(data['totalCount'].toString())) {
        throw Exception('Leave dates, durations and total days do not match.');
      }
      if (data['employeeId']?.toString().trim().isNotEmpty != true ||
          data['reason']?.toString().trim().isNotEmpty != true ||
          data['yearId'] == null ||
          data['leaveNameId'] == null ||
          (num.tryParse(data['totalCount'].toString()) ?? 0) <= 0) {
        throw Exception(
          'Leave request is incomplete. Check employee, year, leave type, dates and reason.',
        );
      }
      final headers = await _hrHeaders();
      if (headers['Authorization']?.isNotEmpty != true) {
        throw Exception('Your session is missing. Please sign in again.');
      }
      final response = sendRequest != null
          ? await sendRequest(ApiEndpoints.leaveCreate, data, headers)
          : await ApiRequest.post(
              ApiEndpoints.leaveCreate,
              data,
              headers: headers,
            );
      return LeaveFormRules.checkedResponse(response);
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
  static Future<Map<String, dynamic>> getMyAttendance({
    String? empId,
    required String monthYear,
  }) async {
    try {
      print(
        'DEBUG: getMyAttendance called with empId: $empId, monthYear: $monthYear',
      );
      final parts = monthYear.split('-');
      DateTime? refDate;
      if (parts.length == 2) {
        refDate = DateTime(
          int.tryParse(parts[1]) ?? DateTime.now().year,
          int.tryParse(parts[0]) ?? DateTime.now().month,
          1,
        );
      }
      print('DEBUG: refDate parsed as: $refDate');
      final id = await _getEffectiveEmpId(empId, referenceDate: refDate);
      print('DEBUG: effective empId resolved as: $id');
      if (id.isEmpty) throw Exception('Employee ID is missing');

      final url = ApiEndpoints.myAttendance(id, monthYear);
      print('DEBUG: making GET request to: $url');
      final response = await ApiRequest.get(url, headers: await _hrHeaders());
      print('DEBUG: getMyAttendance response received');
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching attendance: $e');
      rethrow;
    }
  }

  /// Get Holidays
  /// NOTE: Backend requires POST with name, code, and year filters.

  static Future<dynamic> getHolidays({
    String name = '',
    String code = '',
    String year = '',
  }) async {
    try {
      final payload = {'name': name, 'code': code, 'year': year};

      debugPrint('=== HOLIDAY REQUEST ===');
      debugPrint('URL: ${ApiEndpoints.holidays}');
      debugPrint('Payload: $payload');

      final response = await ApiRequest.post(
        ApiEndpoints.holidays,
        payload,
        headers: await _hrHeaders(),
      );

      debugPrint('Holiday response: $response');
      return response;
    } catch (e) {
      debugPrint('Error fetching holidays: $e');
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
    bool resolveAllEmployees = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ── Resolve empId: use passed value → stored empId → stored userId ──
      final passedEmpId = empId?.trim() ?? '';
      final storedEmpId = prefs.getString('empId')?.trim() ?? '';
      final storedUserId = prefs.getString('userId')?.trim() ?? '';
      final resolvedEmpId = resolveAllEmployees
          ? ''
          : passedEmpId.isNotEmpty
          ? passedEmpId
          : storedEmpId.isNotEmpty
          ? storedEmpId
          : storedUserId;

      // ── Resolve jobTitle from preferences ──
      final resolvedJobTitle =
          jobTitle ??
          prefs.getString('jobtitle') ??
          prefs.getString('UserJobtitle') ??
          prefs.getString('jobTitle') ??
          'admin';

      // ── Resolve employee name for search filter ──
      final resolvedName = resolveAllEmployees
          ? ''
          : searchName.trim().isNotEmpty
          ? searchName.trim()
          : (prefs.getString('firstName') != null
                ? '${prefs.getString('firstName') ?? ''} ${prefs.getString('lastName') ?? ''}'
                      .trim()
                : '');

      final body = {
        'paginationInfo': {
          'pageSize': pageSize,
          'currentPage': page,
          'dataSorting': {
            'sortingOrder': sortingOrder,
            'byColumn': {
              'label': sortingLabel,
              'field': sortingField, // must be 'ed.formal_name' per API
            },
          },
        },
        'branchId': branchId.isNotEmpty
            ? branchId
            : (prefs.get('branchId')?.toString() ?? ''),
        'code': searchCode.trim(),
        'companyId': companyId,
        'departmentId': departmentId,
        'designationId': designationId,
        '#empId': resolvedEmpId, // field name with # as per actual API payload
        'empId': resolvedEmpId, // also send without # for compatibility
        'fromDate': fromDate,
        'jobTitle': resolvedJobTitle,
        'name': resolvedName,
        'toDate': toDate,
      };
      debugPrint('=== SHIFT ROSTER REQUEST ===');
      debugPrint('URL: ${ApiEndpoints.shiftRosterFetch}');
      debugPrint('Clinic: aureus');
      debugPrint('Branch: ${body['branchId']}');
      debugPrint(
        'Employee filter: ${resolveAllEmployees ? "ALL" : resolvedEmpId}',
      );
      debugPrint('Date range: $fromDate to $toDate');
      debugPrint('Job title: $resolvedJobTitle');
      debugPrint('Page size: $pageSize');
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
    return ApiRequest.get(
      ApiEndpoints.leaveView(id),
      headers: await _hrHeaders(),
    );
  }

  static Future<dynamic> cancelLeaveRequest(
    Map<String, dynamic> payload,
  ) async {
    return ApiRequest.put(
      ApiEndpoints.leaveCancel,
      payload,
      headers: await _hrHeaders(),
    );
  }

  static Future<dynamic> deleteLeaveRequest(String id) async {
    return ApiRequest.delete(
      ApiEndpoints.leaveDelete(id),
      headers: await _hrHeaders(),
    );
  }

  // --- Swipe CRUD ---
  static Future<dynamic> getSwipeDashboard(Map<String, dynamic> payload) async {
    return ApiRequest.post(
      ApiEndpoints.swipeDashboard,
      payload,
      headers: await _hrHeaders(),
    );
  }

  static Future<dynamic> createSwipeRequest(
    Map<String, dynamic> payload,
  ) async {
    return ApiRequest.post(
      ApiEndpoints.swipeCreate,
      payload,
      headers: await _hrHeaders(),
    );
  }

  static Future<dynamic> getSwipeRequestById(String id) async {
    return ApiRequest.get(
      ApiEndpoints.swipeView(id),
      headers: await _hrHeaders(),
    );
  }

  static Future<dynamic> updateSwipeRequest(
    Map<String, dynamic> payload,
  ) async {
    return ApiRequest.put(
      ApiEndpoints.swipeUpdate,
      payload,
      headers: await _hrHeaders(),
    );
  }

  static Future<dynamic> deleteSwipeRequest(String id) async {
    return ApiRequest.delete(
      ApiEndpoints.swipeDelete(id),
      headers: await _hrHeaders(),
    );
  }

  // --- OD CRUD ---
  static Future<dynamic> getOdDashboard(Map<String, dynamic> payload) async {
    return ApiRequest.post(
      ApiEndpoints.odDashboard,
      payload,
      headers: await _hrHeaders(),
    );
  }

  static Future<dynamic> createOdRequest(Map<String, dynamic> payload) async {
    return ApiRequest.post(
      ApiEndpoints.odCreate,
      payload,
      headers: await _hrHeaders(),
    );
  }

  static Future<dynamic> getOdRequestById(String id) async {
    return ApiRequest.get(ApiEndpoints.odView(id), headers: await _hrHeaders());
  }

  static Future<dynamic> cancelOdRequest(Map<String, dynamic> payload) async {
    return ApiRequest.put(
      ApiEndpoints.odCancel,
      payload,
      headers: await _hrHeaders(),
    );
  }

  static Future<dynamic> deleteOdRequest(String id) async {
    return ApiRequest.delete(
      ApiEndpoints.odDelete(id),
      headers: await _hrHeaders(),
    );
  }

  /// Update Shift Roster
  static Future<dynamic> updateShiftRoster(
    List<Map<String, dynamic>> data,
  ) async {
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
      final response = await ApiRequest.post(ApiEndpoints.shiftTemplateFetch, {
        'name': searchName.trim(),
        'code': searchCode.trim(),
      }, headers: await _hrHeaders());
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
      final storedEmpId = empId ?? prefs.getString('empId') ?? '';
      final storedUserId = prefs.getString('userId') ?? '';
      final storedBranchId = prefs.get('branchId')?.toString();
      final storedFirstName = prefs.getString('firstName') ?? '';
      final storedLastName = prefs.getString('lastName') ?? '';

      final response = await ApiRequest.post(ApiEndpoints.payrollSummary, {
        'monthYear': monthYear,
        'paginationInfo': {
          'pageSize': pageSize,
          'currentPage': currentPage,
          'dataSorting': {
            'sortingOrder': 'ASC',
            'byColumn': {'label': 'Name', 'field': 'ed.formal_name'},
          },
        },
        'name': name,
        'code': code,
        'companyId': null,
        'branchId': storedBranchId != null
            ? int.tryParse(storedBranchId)
            : null,
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
      }, headers: await _hrHeaders());
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
