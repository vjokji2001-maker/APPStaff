// lib/services/mobile_verification_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mate/APIs/api_endpoints.dart';

class MobileVerificationService {
  // ─── Headers ────────────────────────────────────────────────────────────────

  Future<Map<String, String>> _getHeaders() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String str(String key) => prefs.get(key)?.toString() ?? '';

      final token = str('auth_token');
      final clinicId = str('clinicId');
      final userId = str('userId');
      final branchId = str('branchId').isEmpty ? '1' : str('branchId');

      return {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authorization': token.isNotEmpty ? 'SmartCare $token' : '',
        'clinicid': clinicId,
        'userid': userId,
        'ZONEID': 'Asia/Kolkata',
        'branchId': branchId,
      };
    } catch (e) {
      debugPrint('MobileVerificationService._getHeaders error: $e');
      return {'Content-Type': 'application/json', 'Accept': '*/*'};
    }
  }

  Future<Map<String, String>> _getHeadersWithoutAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String str(String key) => prefs.get(key)?.toString() ?? '';

      final clinicId = str('clinicId');
      final userId = str('userId');
      final branchId = str('branchId').isEmpty ? '1' : str('branchId');

      return {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'clinicid': clinicId,
        'userid': userId,
        'ZONEID': 'Asia/Kolkata',
        'branchId': branchId,
      };
    } catch (e) {
      debugPrint('MobileVerificationService._getHeadersWithoutAuth error: $e');
      return {'Content-Type': 'application/json', 'Accept': '*/*'};
    }
  }

  // ─── Send Mobile OTP ────────────────────────────────────────────────────────

  /// Sends an OTP to [mobileNumber] for [userId].
  /// Uses [ApiEndpoints.userSendMobileOtp].
  Future<Map<String, dynamic>> sendMobileOTP({
    required String mobileNumber,
    required String userId,
  }) async {
    debugPrint('MobileVerificationService: sending OTP to $mobileNumber (userId: $userId)');

    try {
      var headers = await _getHeaders();
      final body = jsonEncode({
        'mobileNo': mobileNumber.trim(),
        'userId': userId.trim(),
      });

      final url = Uri.parse(ApiEndpoints.userSendMobileOtp);
      debugPrint('Send Mobile OTP URL: $url');

      var response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));

      // Retry without auth on 403
      if (response.statusCode == 403) {
        debugPrint('MobileVerificationService: 403, retrying without auth header');
        headers = await _getHeadersWithoutAuth();
        response = await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 30));
      }

      debugPrint('Send Mobile OTP status: ${response.statusCode}');
      debugPrint('Send Mobile OTP body: ${response.body}');

      return _parseResponse(response, successMessage: 'OTP sent to $mobileNumber');
    } catch (e) {
      debugPrint('MobileVerificationService.sendMobileOTP error: $e');
      return {
        'success': false,
        'message': _friendlyError(e),
        'error': e.toString(),
      };
    }
  }

  // ─── Verify Mobile OTP ──────────────────────────────────────────────────────

  /// Verifies [userOtp] for [userId].
  /// Uses [ApiEndpoints.userVerifyMobOtp].
  Future<Map<String, dynamic>> verifyMobileOTP({
    required String userOtp,
    required String userId,
  }) async {
    debugPrint('MobileVerificationService: verifying OTP for userId: $userId');

    try {
      var headers = await _getHeaders();
      final body = jsonEncode({
        'userOtp': userOtp.trim(),
        'userId': userId.trim(),
      });

      final url = Uri.parse(ApiEndpoints.userVerifyMobOtp);
      debugPrint('Verify Mobile OTP URL: $url');

      var response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 403) {
        debugPrint('MobileVerificationService: 403 on verify, retrying without auth');
        headers = await _getHeadersWithoutAuth();
        response = await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 30));
      }

      debugPrint('Verify Mobile OTP status: ${response.statusCode}');
      debugPrint('Verify Mobile OTP body: ${response.body}');

      return _parseResponse(response, successMessage: 'Mobile OTP verified successfully');
    } catch (e) {
      debugPrint('MobileVerificationService.verifyMobileOTP error: $e');
      return {
        'success': false,
        'message': _friendlyError(e),
        'error': e.toString(),
      };
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Map<String, dynamic> _parseResponse(
    http.Response response, {
    required String successMessage,
  }) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final statusCode = decoded['status_code'] ?? decoded['status'] ?? 200;
          final message = (decoded['message'] ?? '').toString();
          return {
            'success': statusCode == 200 || statusCode == 201,
            'statusCode': statusCode,
            'message': message.isNotEmpty ? message : successMessage,
            'data': decoded['data'] ?? {},
            'error': decoded['error'],
          };
        }
      } catch (_) {}
      return {'success': true, 'message': successMessage};
    } else {
      String errorMessage = 'Request failed (${response.statusCode})';
      try {
        final err = jsonDecode(response.body);
        if (err is Map<String, dynamic>) {
          errorMessage = err['message'] ?? err['error'] ?? errorMessage;
        }
      } catch (_) {
        if (response.body.isNotEmpty) errorMessage = response.body;
      }
      return {
        'success': false,
        'message': errorMessage,
        'statusCode': response.statusCode,
      };
    }
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('TimeoutException')) return 'Request timed out. Please try again.';
    if (e is http.ClientException) {
      return 'Connection failed. Please check your internet connection.';
    }
    return 'Network error occurred.';
  }

  // ─── Validators ─────────────────────────────────────────────────────────────

  bool isValidMobile(String mobile) {
    // Accept 10-digit Indian mobile numbers (optionally prefixed with +91 / 91)
    final cleaned = mobile.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    return RegExp(r'^(\+91|91)?[6-9]\d{9}$').hasMatch(cleaned);
  }

  bool isValidOTP(String otp) => RegExp(r'^\d{6}$').hasMatch(otp.trim());

  String normalizeMobile(String mobile) {
    final cleaned = mobile.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleaned.startsWith('+91')) return cleaned.substring(3);
    if (cleaned.startsWith('91') && cleaned.length == 12) return cleaned.substring(2);
    return cleaned;
  }
}
