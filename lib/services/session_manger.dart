import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Add this for Timer

class SessionManager {
  static const String authScheme = 'SmartCare';
  static final Map<String, dynamic> _dynamicData = {};
  
  // Timer for session monitoring
  static Timer? _sessionMonitorTimer;
  static DateTime? _lastActivityTime;
  static Function(bool showDialog)? _onSessionExpiring;
  static bool _isDialogShowing = false;
  static const int sessionTimeoutMinutes = 15;
  static const int warningSeconds = 10;

  // Secure storage for sensitive data
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ─── Secure credential storage (for biometric re-auth) ───────────────────

  static Future<void> saveCredentialsSecurely({
    required String username,
    required String password,
  }) async {
    await _secureStorage.write(key: 'secure_username', value: username);
    await _secureStorage.write(key: 'secure_password', value: password);
  }

  static Future<String?> getSecureUsername() async {
    return await _secureStorage.read(key: 'secure_username');
  }

  static Future<String?> getSecurePassword() async {
    return await _secureStorage.read(key: 'secure_password');
  }

  // ─── Biometric session flag ───────────────────────────────────────────────
  static Future<void> setBiometricSessionActive(bool value) async {
    await _secureStorage.write(
      key: 'biometric_session_active',
      value: value.toString(),
    );
  }

  static Future<bool> isBiometricSessionActive() async {
    final value = await _secureStorage.read(key: 'biometric_session_active');
    return value == 'true';
  }

  // ─── Token storage methods (new) ───────────────────────────────────────────
  
  static Future<void> saveTokens({
    required String? accessToken,
    required String? refreshToken,
    required DateTime? expiryTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (accessToken != null) {
      await prefs.setString('access_token', accessToken);
    }
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
    if (expiryTime != null) {
      await prefs.setString('token_expiry', expiryTime.toIso8601String());
    }
    
    // Update dynamic data
    _dynamicData['access_token'] = accessToken;
    _dynamicData['refresh_token'] = refreshToken;
    _dynamicData['token_expiry'] = expiryTime;
    
    debugPrint('Tokens saved - Expires at: $expiryTime');
  }
  
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
  
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }
  
  static Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString('token_expiry');
    if (expiryStr != null && expiryStr.isNotEmpty) {
      try {
        return DateTime.parse(expiryStr);
      } catch (e) {
        debugPrint('Error parsing token expiry: $e');
        return null;
      }
    }
    return null;
  }
  
  static Future<bool> isTokenValid() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }
  
  static Future<bool> isTokenExpiringSoon() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return false;
    final timeUntilExpiry = expiry.difference(DateTime.now());
    return timeUntilExpiry.inMinutes < 2; // Less than 2 minutes remaining
  }

  // ─── Existing session save (updated) ───────────────────────────────────────

  static Future<void> saveSession({
    required String bearer,
    required String token,
    required String clinicId,
    required int subscriptionRemainingDays,
    required String userId,
    required String zoneid,
    required String expiryTime,
    required int branchId,
    String email = '',
    String? refreshToken, // Add refresh token parameter
    DateTime? tokenExpiry, // Add token expiry parameter
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedBearer = authScheme;

    await prefs.setString('bearer', normalizedBearer);
    await prefs.setString('auth_token', token);
    await prefs.setString('clinicId', clinicId);
    await prefs.setInt('subscription_remaining_days', subscriptionRemainingDays);
    await prefs.setString('userId', userId);
    await prefs.setString('zoneid', zoneid);
    await prefs.setString('expiryTime', expiryTime);
    await prefs.setString('branchId', branchId.toString());
    await prefs.setString('email', email);
    
    // Save tokens for session management
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
    if (tokenExpiry != null) {
      await prefs.setString('token_expiry', tokenExpiry.toIso8601String());
    }
    await prefs.setString('access_token', token); // Access token is the same as auth_token

    _dynamicData.addAll({
      'bearer': normalizedBearer,
      'auth_token': token,
      'clinicId': clinicId,
      'subscription_remaining_days': subscriptionRemainingDays,
      'userId': userId,
      'zoneid': zoneid,
      'expiryTime': expiryTime,
      'branchId': branchId,
      'access_token': token,
      'refresh_token': refreshToken,
      'token_expiry': tokenExpiry,
    });
    
    // Start session monitoring after login
    startSessionMonitoring();
  }

  static Future<void> saveFromApi(Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    
    // Extract refresh token if present
    String? refreshToken = data['refreshToken'];
    DateTime? tokenExpiry;

    if (data['expirytime'] != null && data['expirytime'].toString().isNotEmpty) {
      try {
        tokenExpiry = DateTime.parse(data['expirytime'].toString().replaceFirst(' ', 'T'));
      } catch (_) {}
    } else if (data['expiryTime'] != null && data['expiryTime'].toString().isNotEmpty) {
      try {
        tokenExpiry = DateTime.parse(data['expiryTime'].toString().replaceFirst(' ', 'T'));
      } catch (_) {}
    } else if (data['expiresIn'] != null) {
      tokenExpiry = DateTime.now().add(Duration(seconds: data['expiresIn']));
    } else {
      // No expiry provided — set far future so persistent-login check always passes.
      tokenExpiry = DateTime.now().add(const Duration(days: 3650));
    }
    
    await saveSession(
      bearer: authScheme,
      token: (data['token'] ?? data['accessToken'] ?? '').toString(),
      clinicId: (data['clinicid'] ?? data['clinicId'] ?? '').toString(),
      subscriptionRemainingDays: int.tryParse(
              (data['subscription_remaining_days'] ?? 0).toString()) ?? 0,
      userId: (data['userId'] ?? data['UserId'] ?? '').toString(),
      zoneid: (data['zoneid'] ?? data['ZONEID'] ?? '').toString(),
      expiryTime: (data['expirytime'] ?? data['expiryTime'] ?? '').toString(),
      branchId: int.tryParse((data['branch_id'] ?? 0).toString()) ?? 0,
      email: (data['email'] ?? data['emailId'] ?? data['userEmail'] ?? '').toString(),
      refreshToken: refreshToken,
      tokenExpiry: tokenExpiry,
    );
  }

  // ─── Session monitoring ──────────────────────────────────────────────────────
  //
  // Inactivity-based auto-logout is DISABLED.
  // The session stays alive until the user explicitly calls clearSession() or
  // fullLogout(). All method signatures are kept intact so that existing call
  // sites (ActivityTracker, biometric lock screen, etc.) continue to compile.
  // ─────────────────────────────────────────────────────────────────────────────

  /// No-op — persistent login means we never start an expiry timer.
  static void startSessionMonitoring() {
    // Intentionally empty: auto-logout on inactivity is disabled.
    // Session persists until the user explicitly logs out.
    _lastActivityTime = DateTime.now();
  }

  /// No-op — kept for API compatibility.
  /// Does nothing meaningful since there is no inactivity timer running.
  static void updateUserActivity() {
    _lastActivityTime = DateTime.now();
    _isDialogShowing = false;
    // Callback is intentionally not fired — no expiry dialog needed.
  }

  /// Kept for API compatibility. Callback will never be invoked automatically.
  static void setSessionExpiryCallback(Function(bool showDialog) callback) {
    _onSessionExpiring = callback;
  }

  /// Cancels any lingering timer (e.g. leftover from a previous build).
  /// Safe to call; does NOT clear the session.
  static void stopSessionMonitoring() {
    _sessionMonitorTimer?.cancel();
    _sessionMonitorTimer = null;
    _isDialogShowing = false;
    // _lastActivityTime intentionally left so other code can still read it.
  }

  // ─── Session validation (updated) ───────────────────────────────────────────

  static Future<Map<String, dynamic>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isEmpty) return {};

    int getSafeInt(String key) {
      final dynamic value = prefs.get(key);
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return {
      'bearer': prefs.getString('bearer') ?? '',
      'auth_token': token,
      'clinicId': prefs.getString('clinicId') ?? '',
      'subscriptionRemainingDays': getSafeInt('subscription_remaining_days'),
      'userId': prefs.getString('userId') ?? '',
      'zoneid': prefs.getString('zoneid') ?? '',
      'expiryTime': prefs.getString('expiryTime') ?? '',
      'branchId': getSafeInt('branchId'),
      'access_token': prefs.getString('access_token') ?? token,
      'refresh_token': prefs.getString('refresh_token'),
      'token_expiry': await getTokenExpiry(),
    };
  }

  /// Returns true as long as an auth token (or refresh token) is stored on
  /// disk, regardless of expiry timestamps.  Token expiry is handled silently
  /// at the API layer via token refresh — it should never kick the user back
  /// to the login screen automatically.
  static Future<bool> hasValidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken    = prefs.getString('auth_token')    ?? '';
    final accessToken  = prefs.getString('access_token')  ?? '';
    final refreshToken = prefs.getString('refresh_token') ?? '';
    final hasToken = authToken.isNotEmpty || accessToken.isNotEmpty || refreshToken.isNotEmpty;
    debugPrint('hasValidSession → $hasToken');
    return hasToken;
  }

  // ─── Clear methods (updated) ────────────────────────────────────────────────

  /// Soft logout: clears API session but keeps biometric credentials.
  /// Next app open → biometric screen shows (user just needs to verify face/finger)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    // Preserve these across soft logout
    final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    final lastUsername = prefs.getString('last_username') ?? '';
    final savedEmail = prefs.getString('email') ?? '';

    await prefs.clear();

    if (biometricEnabled) await prefs.setBool('biometric_enabled', true);
    if (lastUsername.isNotEmpty) await prefs.setString('last_username', lastUsername);
    if (savedEmail.isNotEmpty) await prefs.setString('email', savedEmail);

    // Keep biometric session active so lock screen shows on next open
    await setBiometricSessionActive(true);
    
    // Stop session monitoring
    stopSessionMonitoring();

    _dynamicData.clear();
    debugPrint('Session cleared (soft logout).');
  }

  /// Hard logout: clears everything including biometric.
  /// Next app open → full login page, no biometric prompt.
  static Future<void> fullLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
    
    // Stop session monitoring
    stopSessionMonitoring();
    
    _dynamicData.clear();
    debugPrint('Full logout complete.');
  }

  /// Clear only auth data (keep username for biometric re-login)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bearer');
    await prefs.remove('auth_token');
    await prefs.remove('clinicId');
    await prefs.remove('subscription_remaining_days');
    await prefs.remove('userId');
    await prefs.remove('zoneid');
    await prefs.remove('expiryTime');
    await prefs.remove('branchId');
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expiry');
    
    // Stop session monitoring
    stopSessionMonitoring();
    
    _dynamicData.clear();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Now checks secure storage instead of SharedPreferences
  static Future<bool> hasPreviousLogin() async {
    final username = await _secureStorage.read(key: 'secure_username');
    if (username != null && username.isNotEmpty) {
      return true;
    }

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? '';
    final lastUsername = prefs.getString('last_username') ?? '';
    return authToken.isNotEmpty || lastUsername.isNotEmpty;
  }

  static Future<String?> getLastUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_username');
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<String?> getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearer');
  }

  static dynamic getDynamicData(String key) => _dynamicData[key];

  static String formatDate(DateTime dateTime) =>
      DateFormat('dd MMM yyyy').format(dateTime);

  static String formatTime(DateTime dateTime) =>
      DateFormat('hh:mm a').format(dateTime);

  static Future<void> set2FAVerified({required bool verified}) async {}

  static Future<void> debugPrintSession() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('------ SESSION DEBUG START ------');
    for (var key in prefs.getKeys()) {
      debugPrint('$key: ${prefs.get(key)}');
    }
    debugPrint('Access Token: ${await getAccessToken()}');
    debugPrint('Refresh Token: ${await getRefreshToken()}');
    debugPrint('Token Expiry: ${await getTokenExpiry()}');
    debugPrint('------ SESSION DEBUG END ------');
  }
}
// Add this method to SessionManager to verify token storage
Future<void> debugTokenStorage() async {
  final prefs = await SharedPreferences.getInstance();
  debugPrint("======= TOKEN STORAGE DEBUG =======");
  debugPrint("Access Token: ${prefs.getString('access_token')?.substring(0, min(20, prefs.getString('access_token')?.length ?? 0)) ?? 'null'}...");
  debugPrint("Refresh Token: ${prefs.getString('refresh_token') ?? 'null'}");
  debugPrint("Token Expiry: ${prefs.getString('token_expiry') ?? 'null'}");
  debugPrint("Auth Token: ${prefs.getString('auth_token')?.substring(0, min(20, prefs.getString('auth_token')?.length ?? 0)) ?? 'null'}...");
  debugPrint("==================================");
}
