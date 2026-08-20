import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mate/APIs/api_debug_http.dart';
import 'package:staff_mate/APIs/api_endpoints.dart';

class PackageService {
  static String get _packageListIpdUrl => ApiEndpoints.packageListIpd;
  static String get _packageChildListUrl => ApiEndpoints.packageChildList;
  static String get _applyPackageUrl => ApiEndpoints.applyPackage;
  static String get _packageExistsUrl => ApiEndpoints.packageExists;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final clinicId = prefs.getString('clinicId') ?? '';
    final userId = prefs.getString('userId') ?? '';
    final branchId = prefs.getString('branchId') ?? '1';

    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Authorization': 'SmartCare $token',
      'clinicid': clinicId,
      'userid': userId,
      'ZONEID': 'Asia/Kolkata',
      'branchId': branchId,
      'Access-Control-Allow-Origin': '*',
    };
  }

  Future<List<dynamic>> fetchPackageListIpd() async {
    try {
      final headers = await _getHeaders();
      final response = await ApiDebugHttp.get(
        Uri.parse(_packageListIpdUrl),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('packageList')) {
          return decoded['packageList'] ?? [];
        } else if (decoded is List) {
          return decoded;
        }
      }
    } catch (e) {
      debugPrint('Error fetching IPD packages: $e');
    }
    return [];
  }

  Future<List<dynamic>> fetchPackageChildList(String parentId) async {
    try {
      final headers = await _getHeaders();
      final url = '$_packageChildListUrl$parentId';
      final response = await ApiDebugHttp.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('childList')) {
          return decoded['childList'] ?? [];
        } else if (decoded is List) {
          return decoded;
        }
      }
    } catch (e) {
      debugPrint('Error fetching IPD child packages: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> applyPackage({
    required int admissionId,
    required int packageId,
    required double packageAmount,
    required int validity,
    required int childPackageId,
    required int createdBy,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'admissionId': admissionId,
        'packageId': packageId,
        'packageAmount': packageAmount,
        'validity': validity,
        'childPackageId': childPackageId,
        'createdBy': createdBy,
      };

      final response = await ApiDebugHttp.post(
        Uri.parse(_applyPackageUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Package applied successfully'};
      } else {
        return {'success': false, 'message': 'Failed to apply package'};
      }
    } catch (e) {
      debugPrint('Error applying package: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> checkPackageExists(int admissionId) async {
    try {
      final headers = await _getHeaders();
      final body = {'admissionId': admissionId};

      final response = await ApiDebugHttp.post(
        Uri.parse(_packageExistsUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to check package'};
      }
    } catch (e) {
      debugPrint('Error checking package exists: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
