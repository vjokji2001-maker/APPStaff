

import 'package:shared_preferences/shared_preferences.dart';

class ApiHeaders {
  /// Get headers for API requests - Exactly like your React apiHeaders function
  static Future<Map<String, String>> getHeaders({
    String? patientId,
    bool isClinicAdmin = false,
    bool isHrRequest = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final rawAuthToken = prefs.getString('auth_token') ?? '';
    final token = rawAuthToken.replaceAll(RegExp(r'^(SmartCare|Bearer)\s+'), '');
    final authorizationToken = token.isNotEmpty ? '${isHrRequest ? 'Bearer' : 'SmartCare'} $token' : '';
    final zoneId = prefs.getString('ZONEID') ?? 'Asia/Kolkata';
    final userId = prefs.getString('userId') ?? '';
    final branchId = prefs.get('branchId')?.toString() ?? '1';
    final clinicId = prefs.getString('clinicId') ?? '';
    final empid = prefs.getString('empId') ?? '';
    
    return {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'clinicid': isClinicAdmin
          ? 'admin'
          : (isHrRequest
              ? 'hr_staging'
              : (clinicId.isNotEmpty ? clinicId : 'hr_staging')),
      if (authorizationToken.isNotEmpty) 'Authorization': authorizationToken,
      if (zoneId.isNotEmpty) 'zoneid': zoneId,
      if (userId.isNotEmpty) 'userid': userId,
      if (branchId.isNotEmpty) 'branchId': branchId,
      if (patientId != null && patientId.isNotEmpty) 'patientid': patientId,
      if (empid.isNotEmpty) 'empid': empid,
    };
  }
  
  /// Get auth token for specific APIs
  static Future<String> getAuthHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';
    return authToken.startsWith('SmartCare') 
        ? authToken 
        : 'SmartCare $authToken';
  }
}
