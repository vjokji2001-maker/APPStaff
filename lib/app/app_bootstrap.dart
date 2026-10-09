import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mate/pages/settings.dart';
import 'package:staff_mate/services/app_auth_service.dart';
import 'package:staff_mate/services/biometric_auth_service.dart';
import 'package:staff_mate/services/session_manger.dart';

class AppBootstrap {
  static Future<void> loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedFontSize = prefs.getDouble('fontSize') ?? 16.0;
    final savedDarkMode = prefs.getBool('darkMode') ?? false;

    fontSizeNotifier.value = savedFontSize;
    darkModeNotifier.value = savedDarkMode;
  }

  static Future<String> determineStartRoute() async {
    try {
      final hasValidSession = await SessionManager.hasValidSession();
      if (hasValidSession) {
        final biometricEnabled =
            await BiometricAuthService.isBiometricEnabled();
        final biometricAvailable =
            await BiometricAuthService.isBiometricAvailable();

        if (biometricEnabled && biometricAvailable) {
          return '/biometric-lock';
        }

        try {
          final refreshResult = await const AppAuthService().refreshSession();
          if (!refreshResult.isSuccess) {
            debugPrint('Silent token refresh failed: ${refreshResult.failure}');
          }
        } catch (e) {
          debugPrint('Silent token refresh failed: $e');
        }

        SessionManager.updateUserActivity();
        SessionManager.startSessionMonitoring();
        return '/dashboard';
      }

      final hasPreviousLogin = await SessionManager.hasPreviousLogin();
      if (!hasPreviousLogin) {
        return '/login';
      }

      return '/login';
    } catch (e) {
      debugPrint('determineStartRoute error: $e');
      return '/login';
    }
  }
}
